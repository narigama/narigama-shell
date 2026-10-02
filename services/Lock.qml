pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pam
import Quickshell.Wayland
import qs.config

// Lock state and PAM password auth; the surfaces are in shell.qml. Locks on logind's Lock signal
// (the menu's Lock button, `loginctl lock-session`), before suspend, after ShellState.lockIdleMinutes
// idle, and over IPC. Only the password unlocks: logind's Unlock is ignored, as anything running as
// the user could send it. The state is kept in a runtime file so a restarted shell relocks.
Singleton {
    id: root

    property bool locked: false
    // True from a successful unlock until the overlay has slid away (modules/LockReveal.qml).
    property bool revealing: false
    property double lockedAt: 0
    // The password field's text, shared by every screen's surface.
    property string password: ""
    property bool authenticating: false
    property string message: ""
    property bool messageIsError: false
    readonly property int unreadSinceLock: ShellState.lockShowNotifications ? Notifications.history.filter(e => e.time > lockedAt).length : 0

    readonly property string sessionId: Quickshell.env("XDG_SESSION_ID")
    // logind object path for this session, e.g. /org/freedesktop/login1/session/_34.
    property string sessionPath: ""
    readonly property string runtimeFlag: (Quickshell.env("XDG_RUNTIME_DIR") || "/tmp") + "/narigama-shell-locked"

    // Per-screen snapshots of the desktop taken just before locking, so the lock can slide in over
    // them (once locked, the compositor shows nothing behind the lock). Deleted on unlock.
    readonly property string snapshotDir: Quickshell.env("XDG_RUNTIME_DIR") || "/tmp"
    property bool capturing: false
    // Whether this lock has snapshots to slide in over.
    property bool hasSnapshot: false

    function snapshotPath(screenName) {
        return snapshotDir + "/narigama-lock-" + screenName + ".png";
    }

    function lock() {
        if (locked || capturing)
            return;

        password = "";
        message = "";

        if (!Tools.has("grim")) {
            hasSnapshot = false;
            engage();
            return;
        }

        capturing = true;
        snapshot.command = ["sh", "-c", Quickshell.screens.map(s => "grim -o '" + s.name + "' '" + snapshotPath(s.name) + "' &").join(" ") + " wait"];
        hasSnapshot = true;
        snapshot.running = true;
        snapshotTimeout.restart();
    }

    function engage() {
        capturing = false;
        snapshotTimeout.stop();
        lockedAt = Date.now();
        locked = true;
    }

    // The overlay copies the lock's look onto the desktop, the lock is released underneath it a
    // couple of frames later, then the overlay slides up to reveal the live desktop.
    function unlock() {
        pam.abort();
        authenticating = false;
        password = "";
        revealing = true;
        release.restart();
    }

    function revealDone() {
        revealing = false;
        Quickshell.execDetached(["sh", "-c", "rm -f '" + snapshotDir + "'/narigama-lock-*.png"]);
    }

    Timer {
        id: release

        interval: 60
        onTriggered: root.locked = false
    }

    Process {
        id: snapshot

        onExited: root.engage()
    }

    // Never let a slow capture delay the lock.
    Timer {
        id: snapshotTimeout

        interval: 800
        onTriggered: {
            if (root.capturing) {
                root.hasSnapshot = false;
                root.engage();
            }
        }
    }

    function submit() {
        if (authenticating || password === "")
            return;

        authenticating = true;
        message = "";
        pam.start();
    }

    onLockedChanged: {
        Quickshell.execDetached(["sh", "-c", (locked ? "touch '" : "rm -f '") + runtimeFlag + "'"]);

        if (sessionPath !== "")
            Quickshell.execDetached(["busctl", "--system", "call", "org.freedesktop.login1", sessionPath, "org.freedesktop.login1.Session", "SetLockedHint", "b", String(locked)]);
    }

    // A previous instance was locked when it went away; relock (needs the compositor to allow it,
    // e.g. Hyprland's misc:allow_session_lock_restore).
    Process {
        running: true
        command: ["sh", "-c", "rm -f '" + root.snapshotDir + "'/narigama-lock-*.png; [ -e '" + root.runtimeFlag + "' ] && echo locked"]
        stdout: StdioCollector {
            onStreamFinished: {
                if (text.trim() === "locked") {
                    root.hasSnapshot = false;
                    root.engage();
                }
            }
        }
    }

    Process {
        running: root.sessionId !== ""
        command: ["busctl", "--system", "call", "org.freedesktop.login1", "/org/freedesktop/login1", "org.freedesktop.login1.Manager", "GetSession", "s", root.sessionId]
        stdout: StdioCollector {
            onStreamFinished: root.sessionPath = (text.split('"')[1] ?? "")
        }
    }

    PamContext {
        id: pam

        config: "system-auth"

        onResponseRequiredChanged: {
            if (responseRequired) {
                respond(root.password);
                root.password = "";
            }
        }

        onPamMessage: {
            if (message !== "" && !responseRequired) {
                root.message = message;
                root.messageIsError = messageIsError;
            }
        }

        onCompleted: result => {
            root.authenticating = false;

            if (result === PamResult.Success) {
                root.unlock();
                return;
            }

            root.message = result === PamResult.MaxTries ? "Too many attempts, wait a moment" : "Wrong password";
            root.messageIsError = true;
        }

        onError: error => {
            root.authenticating = false;
            root.message = "Authentication error: " + PamError.toString(error);
            root.messageIsError = true;
        }
    }

    IdleMonitor {
        enabled: ShellState.lockOnIdle && !root.locked
        timeout: ShellState.lockIdleMinutes * 60
        respectInhibitors: true
        onIsIdleChanged: {
            if (isIdle)
                root.lock();
        }
    }

    // logind's Lock for this session, and PrepareForSleep. Run directly (no shell pipeline), so a
    // reload stops it rather than leaving it orphaned.
    Process {
        running: root.sessionPath !== ""
        command: ["gdbus", "monitor", "--system", "--dest", "org.freedesktop.login1"]
        stdout: SplitParser {
            onRead: line => {
                if (line.startsWith(root.sessionPath + ": org.freedesktop.login1.Session.Lock"))
                    root.lock();
                else if (line.includes("org.freedesktop.login1.Manager.PrepareForSleep (true")) {
                    if (ShellState.lockBeforeSleep)
                        root.lock();

                    releaseSleep.restart();
                } else if (line.includes("org.freedesktop.login1.Manager.PrepareForSleep (false"))
                    sleepInhibitor.running = true;
            }
        }
    }

    // Delays suspend until the lock is up, so the screen is never shown unlocked on wake.
    Process {
        id: sleepInhibitor

        running: root.sessionId !== "" && ShellState.lockBeforeSleep
        command: ["systemd-inhibit", "--what=sleep", "--mode=delay", "--who=narigama-shell", "--why=Lock the screen before sleeping", "sleep", "infinity"]
    }

    Timer {
        id: releaseSleep

        interval: 500
        onTriggered: sleepInhibitor.running = false
    }

    // qs ipc call lock lock   (there's deliberately no unlock)
    IpcHandler {
        target: "lock"

        function lock(): void {
            root.lock();
        }

        function isLocked(): bool {
            return root.locked;
        }
    }
}

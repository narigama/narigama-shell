pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications
import qs.config

// Notification daemon: history (persisted), popups and do-not-disturb.
// Only one process can own org.freedesktop.Notifications; while another daemon
// holds it, this server waits and takes over once it's released.
Singleton {
    id: root

    // Newest first. Plain objects so entries outlive the Notification that created them.
    property var history: []
    // Keys of history entries currently shown as popups, newest first.
    property var popupKeys: []
    // Popups sliding out: key -> time hidden. They stay in popupKeys until the slide finishes.
    property var leaving: ({})
    readonly property int leaveMs: 220
    readonly property int count: history.length
    readonly property bool dnd: ShellState.notificationsDnd

    readonly property int duplicateWindowMs: 2000

    // Live Notification objects by entry key, for actions and dismissal while the sender still cares.
    // Keys rather than notification ids, since ids restart with the daemon but history persists.
    property var live: ({})

    // Newest group first; entries within a group stay newest first.
    readonly property var groups: {
        const byApp = {};
        const order = [];

        for (const item of history) {
            const app = appName(item);

            if (!byApp[app]) {
                byApp[app] = [];
                order.push(app);
            }

            byApp[app].push(item);
        }

        return order.map(app => ({
                    "app": app,
                    "entries": byApp[app],
                    "latest": byApp[app][0].time,
                    "icon": appIconSource(byApp[app].find(e => e.appIcon)?.appIcon ?? "")
                }));
    }

    // Apps whose group is expanded in the dropdown; kept here so it survives reopening.
    property var expandedApps: []

    function appName(item) {
        return item.appName || "Notification";
    }

    function appIconSource(appIcon) {
        if (!appIcon)
            return "";

        if (appIcon.startsWith("file://"))
            return appIcon;

        if (appIcon.startsWith("/"))
            return "file://" + appIcon;

        return Quickshell.iconPath(appIcon, true);
    }

    function toggleExpanded(app) {
        expandedApps = expandedApps.includes(app) ? expandedApps.filter(a => a !== app) : expandedApps.concat([app]);
    }

    function isMuted(app) {
        return ShellState.mutedApps.includes(app);
    }

    function setMuted(app, muted) {
        ShellState.mutedApps = muted ? ShellState.mutedApps.filter(a => a !== app).concat([app]) : ShellState.mutedApps.filter(a => a !== app);
    }

    function clearApp(app) {
        const keys = history.filter(e => appName(e) === app).map(e => e.key);

        for (const key of keys) {
            live[key]?.dismiss();
            delete live[key];
            hidePopup(key);
        }

        history = history.filter(e => appName(e) !== app);
        expandedApps = expandedApps.filter(a => a !== app);
        save();
    }

    function entry(key) {
        return history.find(e => e.key === key) ?? null;
    }

    function setDnd(value) {
        ShellState.notificationsDnd = value;

        if (value)
            popupKeys.forEach(hidePopup);
    }

    function isLeaving(key) {
        return leaving[key] !== undefined;
    }

    function hidePopup(key) {
        if (!popupKeys.includes(key) || isLeaving(key))
            return;

        const next = Object.assign({}, leaving);

        next[key] = Date.now();
        leaving = next;
    }

    // Closing a popup deletes it from history too.
    function remove(key) {
        live[key]?.dismiss();
        delete live[key];
        hidePopup(key);
        history = history.filter(e => e.key !== key);
        save();
    }

    function clearAll() {
        for (const key in live)
            live[key].dismiss();

        live = {};
        popupKeys.forEach(hidePopup);
        history = [];
        expandedApps = [];
        save();
    }

    function invoke(key, actionIdentifier) {
        const notification = live[key];
        const action = notification?.actions.find(a => a.identifier === actionIdentifier);

        action?.invoke();
        hidePopup(key);
    }

    function save() {
        historyFile.setText(JSON.stringify(history));
    }

    Timer {
        interval: 50
        repeat: true
        running: Object.keys(root.leaving).length > 0
        onTriggered: {
            const now = Date.now();
            const done = Object.keys(root.leaving).filter(k => now - root.leaving[k] >= root.leaveMs);

            if (done.length === 0)
                return;

            const next = Object.assign({}, root.leaving);

            done.forEach(k => delete next[k]);
            root.popupKeys = root.popupKeys.filter(p => !done.includes(p));
            root.leaving = next;
        }
    }

    NotificationServer {
        id: server

        keepOnReload: true
        actionsSupported: true
        bodyMarkupSupported: true
        bodySupported: true
        imageSupported: true
        persistenceSupported: true

        onNotification: notification => {
            notification.tracked = true;

            // Some apps (Slack) send each message twice in quick succession under different ids;
            // fold the repeat into the first entry, keeping the newer object for actions.
            const duplicate = root.history.find(e => Date.now() - e.time < root.duplicateWindowMs && e.appName === notification.appName && e.summary === notification.summary && e.body === notification.body);
            const key = duplicate?.key ?? notification.id + ":" + Date.now();

            root.live[key] = notification;
            notification.closed.connect(() => {
                if (root.live[key] === notification)
                    delete root.live[key];
            });

            if (duplicate)
                return;

            const item = {
                "key": key,
                "appName": notification.appName,
                "appIcon": notification.appIcon,
                "image": notification.image.startsWith("image://") ? "" : notification.image,
                "summary": notification.summary,
                "body": notification.body,
                "urgency": notification.urgency,
                "actions": notification.actions.map(a => ({
                            "identifier": a.identifier,
                            "text": a.text
                        })),
                "time": Date.now()
            };

            root.history = [item].concat(root.history).slice(0, Config.notificationHistoryMax);
            root.save();

            const critical = notification.urgency === NotificationUrgency.Critical;

            if (critical || (!root.dnd && !root.isMuted(root.appName(item))))
                root.popupKeys = [key].concat(root.popupKeys).slice(0, ShellState.popupMax);
        }
    }

    FileView {
        id: historyFile

        path: Quickshell.statePath("notifications.json")
        blockLoading: true
        atomicWrites: true
        printErrors: false

        onLoaded: {
            try {
                root.history = JSON.parse(text());
            } catch (e) {
                root.history = [];
            }
        }
    }
}

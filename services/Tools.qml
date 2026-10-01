pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.config

// Which external tools are installed, and which distro family we're on, so modules whose tools
// are missing can be disabled with a hint naming the packages to install.
Singleton {
    id: root

    // "arch", "debian", "fedora" or "" (unknown).
    property string distro: ""
    // os-release ID as-is (e.g. "endeavouros"), for the logo.
    property string distroId: ""
    // XDG user directories (localised names, user overrides).
    property string picturesDir: Quickshell.env("HOME") + "/Pictures"
    property string videosDir: Quickshell.env("HOME") + "/Videos"
    // From $TERMINAL, xdg-terminal-exec or the first common terminal installed.
    property string terminal: ""
    property var installed: []
    property bool ready: false

    // command -> package that provides it, where the names differ.
    readonly property var packageFor: ({
            "wl-copy": "wl-clipboard",
            "wl-paste": "wl-clipboard",
            "gamemoded": "gamemode"
        })

    // Commands each module needs. Optional extras (satty, wf-recorder) are checked by the module.
    readonly property var requirements: ({
            "updates": [],
            "failedUnits": ["systemctl"],
            "capture": ["grim", "slurp", "wl-copy"],
            "clipboard": ["cliphist", "wl-copy", "wl-paste"],
            "colorPicker": ["hyprpicker", "wl-copy"],
            "brightness": ["ddcutil"],
            "gamemode": ["gamemoded"]
        })

    readonly property var checked: ["systemctl", "grim", "slurp", "wl-copy", "wl-paste", "satty", "wf-recorder", "cliphist", "hyprpicker", "ddcutil", "gamemoded", "pacman", "fakeroot", "paru", "yay", "apt", "dnf", "awww", "swaybg", "matugen", "vipsthumbnail", "magick"]

    // Package manager used for update checks: "pacman", "apt", "dnf" or "".
    readonly property string packageManager: has("pacman") ? "pacman" : has("apt") ? "apt" : has("dnf") ? "dnf" : ""
    readonly property string aurHelper: has("paru") ? "paru" : has("yay") ? "yay" : ""

    // How each terminal takes a command to run; anything else (e.g. from $TERMINAL) gets -e.
    readonly property var terminalArgs: ({
            "xdg-terminal-exec": [],
            "foot": [],
            "kitty": [],
            "alacritty": ["-e"],
            "wezterm": ["start", "--"],
            "ghostty": ["-e"],
            "gnome-terminal": ["--"],
            "konsole": ["-e"]
        })
    readonly property var terminalCommand: {
        if (Config.terminalCommand.length)
            return Config.terminalCommand;

        const [name, ...args] = terminal.split(" ").filter(a => a !== "");

        if (!name)
            return [];

        return [name].concat(args.length ? args : (terminalArgs[name.split("/").pop()] ?? ["-e"]));
    }

    function has(command) {
        return installed.includes(command);
    }

    function packageName(command) {
        return packageFor[command] ?? command;
    }

    // Packages to install before `module` can work; empty when it's ready (or not checked yet).
    function missingPackages(module) {
        if (!ready)
            return [];

        const missing = [];

        if (module === "updates") {
            if (packageManager === "")
                return ["(pacman, apt or dnf)"];

            if (packageManager === "pacman" && !has("fakeroot"))
                missing.push("fakeroot");
        }

        if (module === "wallpapers") {
            if (!has("awww") && !has("swaybg"))
                missing.push("awww");

            if (!has("vipsthumbnail") && !has("magick"))
                missing.push(distro === "debian" ? "libvips-tools" : distro === "fedora" ? "vips-tools" : "libvips");
        }

        for (const command of requirements[module] ?? []) {
            const pkg = packageName(command);

            if (!has(command) && !missing.includes(pkg))
                missing.push(pkg);
        }

        return missing;
    }

    function available(module) {
        return missingPackages(module).length === 0;
    }

    function installCommand(packages) {
        const list = packages.join(" ");

        if (distro === "arch")
            return "sudo pacman -S " + list;

        if (distro === "debian")
            return "sudo apt install " + list;

        if (distro === "fedora")
            return "sudo dnf install " + list;

        return "install " + list;
    }

    // e.g. "Needs grim, slurp · sudo apt install grim slurp"
    function hint(module) {
        const missing = missingPackages(module);

        if (missing.length === 0)
            return "";

        if (module === "updates" && packageManager === "")
            return "Supports pacman, apt and dnf";

        return "Needs " + missing.join(", ") + " · " + installCommand(missing);
    }

    function optionalHint(command) {
        return has(command) ? "" : "Needs " + packageName(command) + " · " + installCommand([packageName(command)]);
    }

    Process {
        running: true
        command: ["sh", "-c", `
            . /etc/os-release 2>/dev/null
            echo "distro $ID $ID_LIKE"
            echo "id $ID"
            echo "pictures $(xdg-user-dir PICTURES 2>/dev/null || echo "$HOME/Pictures")"
            echo "videos $(xdg-user-dir VIDEOS 2>/dev/null || echo "$HOME/Videos")"
            if [ -n "$TERMINAL" ] && command -v "\${TERMINAL%% *}" >/dev/null 2>&1; then
                echo "terminal $TERMINAL"
            else
                for t in xdg-terminal-exec foot kitty alacritty wezterm ghostty gnome-terminal konsole; do
                    command -v "$t" >/dev/null 2>&1 && { echo "terminal $t"; break; }
                done
            fi
            for c in ${root.checked.join(" ")}; do command -v "$c" >/dev/null 2>&1 && echo "$c"; done`]
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.trim().split("\n");
                const field = name => (lines.find(l => l.startsWith(name + " ")) ?? "").slice(name.length + 1).trim();
                const ids = field("distro").split(/\s+/);

                root.distro = ids.includes("arch") ? "arch" : ids.some(id => ["debian", "ubuntu"].includes(id)) ? "debian" : ids.some(id => ["fedora", "rhel", "centos"].includes(id)) ? "fedora" : "";
                root.distroId = field("id");
                root.picturesDir = field("pictures") || root.picturesDir;
                root.videosDir = field("videos") || root.videosDir;
                root.terminal = field("terminal");
                root.installed = lines.filter(l => !/^(distro|id|pictures|videos|terminal) /.test(l));
                root.ready = true;
            }
        }
    }
}

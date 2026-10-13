pragma Singleton

import QtQuick
import Quickshell

// Active palette and sizing; the palette comes from config/Themes.qml via the saved theme id.
Singleton {
    readonly property var current: Themes.find(ShellState.theme)
    readonly property bool fromWallpaper: ShellState.matchWallpaper && ShellState.wallpaperColors !== null
    readonly property bool light: fromWallpaper ? ShellState.wallpaperThemeMode === "light" : current.light
    // callLater coalesces a theme change that also moves lastDark/LightTheme into one run.
    onLightChanged: Qt.callLater(applyToApps)
    Component.onCompleted: Qt.callLater(applyToApps)

    Connections {
        target: ShellState

        function onLastDarkThemeChanged() {
            Qt.callLater(Theme.applyToApps);
        }

        function onLastLightThemeChanged() {
            Qt.callLater(Theme.applyToApps);
        }
    }

    // kitty picks dark-/light-theme.auto.conf from the portal color-scheme, so both are kept
    // written before the scheme flips; USR1 makes running kittys reload a same-mode theme change.
    // gtk-theme before color-scheme: Electron apps (Slack) re-derive the scheme from a gtk-theme change and land on light.
    readonly property string appsScript: 'if command -v kitten >/dev/null; then
    dir="${XDG_CONFIG_HOME:-$HOME/.config}/kitty"
    kitten themes --dump-theme --cache-age=30 "$3" > "$dir/dark-theme.auto.conf.tmp" && mv "$dir/dark-theme.auto.conf.tmp" "$dir/dark-theme.auto.conf"
    kitten themes --dump-theme --cache-age=30 "$4" > "$dir/light-theme.auto.conf.tmp" && mv "$dir/light-theme.auto.conf.tmp" "$dir/light-theme.auto.conf"
    rm -f "$dir"/*-theme.auto.conf.tmp
    pkill -USR1 -x kitty
fi
gsettings set org.gnome.desktop.interface gtk-theme "$1" && gsettings set org.gnome.desktop.interface color-scheme "$2"'

    function applyToApps() {
        if (!ShellState.themeModeToApps)
            return;

        Quickshell.execDetached(["sh", "-c", appsScript, "sh", light ? "Adwaita" : "Adwaita-dark", light ? "prefer-light" : "prefer-dark", Themes.find(ShellState.lastDarkTheme).kitty, Themes.find(ShellState.lastLightTheme).kitty]);
    }

    readonly property var colors: fromWallpaper ? ShellState.wallpaperColors : current.colors

    readonly property color bg: colors.bg
    readonly property color surface: colors.surface
    readonly property color elevated: colors.elevated
    readonly property color fg: colors.fg
    readonly property color fgMuted: colors.fgMuted
    readonly property color fgSubtle: colors.fgSubtle
    readonly property color primary: colors.primary
    readonly property color red: colors.red
    readonly property color yellow: colors.yellow
    readonly property color green: colors.green
    readonly property color blue: colors.blue

    // The saved fonts, unless fontconfig says they aren't installed: then the first Nerd Font, so
    // icons never render as boxes (and plain monospace if there's no Nerd Font at all).
    readonly property string fontFamily: Fonts.textFonts.length === 0 || Fonts.textFonts.includes(ShellState.fontFamily) ? ShellState.fontFamily : (Fonts.iconFonts[0] ?? "monospace")
    // Glyph-only text uses this; mixed text relies on fontconfig falling back to a Nerd Font.
    readonly property string iconFontFamily: Fonts.iconFonts.length === 0 || Fonts.iconFonts.includes(ShellState.iconFontFamily) ? ShellState.iconFontFamily : Fonts.iconFonts[0]
    readonly property int fontSize: ShellState.fontSize
    readonly property int iconSize: ShellState.iconSize

    // 37px at the default sizes; grows if the text or icons need more room.
    readonly property int barHeight: Math.max(37, iconSize + 13, fontSize + 22)
    readonly property int buttonPadding: 8
    readonly property int iconGap: 8
    readonly property int workspacePadding: 9
    readonly property int workspaceMinWidth: 25
}

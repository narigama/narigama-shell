pragma Singleton

import QtQuick
import Quickshell

// Active palette and sizing; the palette comes from config/Themes.qml via the saved theme id.
Singleton {
    readonly property var current: Themes.find(ShellState.theme)
    readonly property bool fromWallpaper: ShellState.matchWallpaper && ShellState.wallpaperColors !== null
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

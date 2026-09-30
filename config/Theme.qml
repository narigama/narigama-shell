pragma Singleton

import QtQuick
import Quickshell

// Active palette and sizing; the palette comes from config/Themes.qml via the saved theme id.
Singleton {
    readonly property var current: Themes.find(ShellState.theme)
    readonly property var colors: current.colors

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

    readonly property string fontFamily: ShellState.fontFamily
    // Glyph-only text uses this; mixed text relies on fontconfig falling back to a Nerd Font.
    readonly property string iconFontFamily: ShellState.iconFontFamily
    readonly property int fontSize: ShellState.fontSize
    readonly property int iconSize: ShellState.iconSize

    // 37px at the default sizes; grows if the text or icons need more room.
    readonly property int barHeight: Math.max(37, iconSize + 13, fontSize + 22)
    readonly property int buttonPadding: 8
    readonly property int iconGap: 8
    readonly property int workspacePadding: 9
    readonly property int workspaceMinWidth: 25
}

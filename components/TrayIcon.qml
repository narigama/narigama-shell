import QtQuick
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import qs.config

// A tray item's icon, with a generic glyph for apps whose icon name doesn't resolve.
Item {
    id: root

    required property SystemTrayItem item
    property int size: 20
    // The icon provider draws a placeholder rather than failing, so check the theme first.
    readonly property string themeIconName: item.icon.startsWith("image://icon/") ? item.icon.slice("image://icon/".length).split("?")[0] : ""
    readonly property bool iconMissing: themeIconName !== "" && Quickshell.iconPath(themeIconName, true) === ""

    implicitWidth: size
    implicitHeight: size

    IconImage {
        anchors.fill: parent
        visible: !root.iconMissing
        implicitSize: root.size
        source: root.item.icon
    }

    StyledText {
        anchors.centerIn: parent
        visible: root.iconMissing
        text: Icons.application
        font.family: Theme.iconFontFamily
        color: Theme.fgMuted
        font.pixelSize: root.size
    }
}

import QtQuick
import Quickshell.Services.Mpris
import qs.components
import qs.config
import qs.services

BarButton {
    id: root

    readonly property MprisPlayer player: Media.active

    implicitWidth: contentRow.width + 2 * Theme.buttonPadding
    leftDropdown: "media"

    Row {
        id: contentRow

        x: Theme.buttonPadding
        height: parent.height
        spacing: Theme.iconGap

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: Icons.forPlayer(root.player)
            color: Theme.blue
            font.family: Theme.iconFontFamily
            font.pixelSize: 24
        }

        RollingText {
            visible: text !== ""
            text: root.player ? `${root.player.trackTitle ?? ""} - ${root.player.trackArtist ?? ""}` : ""
            color: Theme.blue
            bold: true
            maxWidth: Theme.fontSize * 16
        }
    }
}

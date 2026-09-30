import QtQuick
import Quickshell.Services.Mpris
import qs.components
import qs.config
import qs.services

BarButton {
    id: root

    readonly property MprisPlayer player: Media.active
    readonly property int labelMaxLength: 35
    readonly property string fullLabel: player ? `${player.trackTitle ?? ""} - ${player.trackArtist ?? ""}` : ""

    visible: player !== null && ShellState.moduleVisible("media")
    icon: Icons.forPlayer(player)
    iconSize: 24
    label: fullLabel.length > labelMaxLength ? fullLabel.slice(0, labelMaxLength - 1) + "…" : fullLabel
    color: Theme.blue
    leftDropdown: "media"
}

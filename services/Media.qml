pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Mpris

// Picks the player the bar and media dropdown both show.
Singleton {
    id: root

    // Browsers expose every tab with audio (videos, calls, meetings) over MPRIS; leave them out.
    readonly property var browserPattern: /chrom|firefox|brave|vivaldi|edge|opera|zen|librewolf|floorp|epiphany|qutebrowser|falkon|midori|mercury|waterfox|thorium/i
    readonly property var players: Mpris.players.values.filter(p => !browserPattern.test((p.desktopEntry || "") + " " + (p.identity || "") + " " + (p.dbusName || "")))
    // Set when the user picks a player in the dropdown; otherwise follow whatever is playing.
    property MprisPlayer chosen: null
    readonly property MprisPlayer active: players.includes(chosen) ? chosen : players.find(p => p.isPlaying) ?? players[0] ?? null

    function playerName(player) {
        return player?.identity || player?.desktopEntry || "Player";
    }

    // MPRIS doesn't signal position changes during playback, so poll while something plays.
    Timer {
        interval: 1000
        repeat: true
        running: root.active?.isPlaying ?? false
        onTriggered: root.active.positionChanged()
    }
}

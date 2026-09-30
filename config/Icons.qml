pragma Singleton

import QtQuick
import Quickshell

// Nerd Font glyphs, named after their nf-* identifiers.
Singleton {
    id: root

    readonly property string calendarClock: glyph(0xf00f0)
    readonly property string cpu: glyph(0xf4bc)
    readonly property string memory: glyph(0xefc5)
    readonly property string archlinux: glyph(0xf303)

    readonly property var volumeLevels: [glyph(0xf057f), glyph(0xf0580), glyph(0xf057e)]
    readonly property string volumeHigh: volumeLevels[2]
    readonly property string volumeOff: glyph(0xf0581)

    readonly property string bell: glyph(0xf009c)
    readonly property string bellBadge: glyph(0xf0178)
    readonly property string bellOff: glyph(0xf0a91)

    readonly property var wifiStrength: [glyph(0xf091f), glyph(0xf0922), glyph(0xf0925), glyph(0xf0928)]
    readonly property string wifiOffline: glyph(0xf092f)
    readonly property string wifiOff: glyph(0xf092e)
    readonly property string wifiAlert: glyph(0xf092b)
    readonly property string ethernet: glyph(0xf0200)
    readonly property string lanDisconnect: glyph(0xf0319)

    readonly property string bluetooth: glyph(0xf00af)
    readonly property string bluetoothConnect: glyph(0xf00b1)
    readonly property string bluetoothOff: glyph(0xf00b2)
    readonly property string bluetoothSearching: glyph(0xf00b3)

    readonly property string music: glyph(0xf075a)
    readonly property string application: glyph(0xf08c6)

    readonly property string chevronLeft: glyph(0xf0141)
    readonly property string chevronRight: glyph(0xf0142)
    readonly property string chevronDown: glyph(0xf0140)
    readonly property string close: glyph(0xf0156)
    readonly property string check: glyph(0xf012c)
    readonly property string refresh: glyph(0xf0450)
    readonly property string lock: glyph(0xf033e)
    readonly property string lockOutline: glyph(0xf0341)
    readonly property string logout: glyph(0xf0343)
    readonly property string restart: glyph(0xf0709)
    readonly property string power: glyph(0xf0425)
    readonly property string account: glyph(0xf0b55)
    readonly property string clock: glyph(0xf0150)
    readonly property string thermometer: glyph(0xf050f)
    readonly property string humidity: glyph(0xf058e)
    readonly property string wind: glyph(0xf059d)
    readonly property string deleteSweep: glyph(0xf0c62)
    readonly property string monitor: glyph(0xf0379)
    readonly property string cog: glyph(0xf0493)

    readonly property string play: glyph(0xf040a)
    readonly property string pause: glyph(0xf03e4)
    readonly property string skipNext: glyph(0xf04ad)
    readonly property string skipPrevious: glyph(0xf04ae)
    readonly property string shuffle: glyph(0xf049f)
    readonly property string repeat: glyph(0xf0456)
    readonly property string repeatOnce: glyph(0xf0458)
    readonly property string repeatOff: glyph(0xf0457)

    readonly property string speaker: glyph(0xf04c3)
    readonly property string headphones: glyph(0xf02cb)
    readonly property string microphone: glyph(0xf036c)
    readonly property string microphoneOff: glyph(0xf036d)

    readonly property string headset: glyph(0xf02ce)
    readonly property string keyboard: glyph(0xf030c)
    readonly property string capsLock: glyph(0xf0632)
    readonly property string camera: glyph(0xf05a0)
    readonly property string screenShare: glyph(0xf1483)
    readonly property string arrowDown: glyph(0xf0045)
    readonly property string arrowUp: glyph(0xf005d)
    readonly property string gpu: glyph(0xf08ae)
    readonly property string palette: glyph(0xf03d8)
    readonly property string lightning: glyph(0xf140b)
    readonly property string mouse: glyph(0xf037d)
    readonly property string phone: glyph(0xf011c)

    readonly property var weather: ({
            "sunny": glyph(0xf0599),
            "night": glyph(0xf0594),
            "partlyCloudy": glyph(0xf0595),
            "nightPartlyCloudy": glyph(0xf0f31),
            "cloudy": glyph(0xf0590),
            "fog": glyph(0xf0591),
            "rainy": glyph(0xf0597),
            "pouring": glyph(0xf0596),
            "snowy": glyph(0xf0598),
            "snowyRainy": glyph(0xf067f),
            "lightning": glyph(0xf0593),
            "lightningRainy": glyph(0xf067e),
            "hail": glyph(0xf0592)
        })

    readonly property var players: ({
            "chrome": glyph(0xf02af),
            "chromium": glyph(0xf02af),
            "firefox": glyph(0xf0239),
            "spotify": glyph(0xf04c7),
            "vlc": glyph(0xf057c)
        })

    function glyph(codePoint) {
        return String.fromCodePoint(codePoint);
    }

    // BlueZ device icon names follow the freedesktop "audio-headset"-style scheme.
    function forBluetoothDevice(device) {
        const name = device?.icon ?? "";

        if (name.includes("headset") || name.includes("headphone"))
            return headphones;

        if (name.includes("audio"))
            return speaker;

        if (name.includes("keyboard"))
            return keyboard;

        if (name.includes("mouse") || name.includes("input"))
            return mouse;

        return name.includes("phone") ? phone : bluetooth;
    }

    function forPlayer(player) {
        const key = ((player?.desktopEntry || player?.identity) ?? "").toLowerCase();

        for (const name in players) {
            if (key.includes(name))
                return players[name];
        }

        return music;
    }

    // The 1-100% range is split evenly across the level icons.
    function forVolume(volume, muted) {
        if (muted)
            return volumeOff;

        const index = Math.ceil(Math.round(volume * 100) / (100 / volumeLevels.length)) - 1;

        return volumeLevels[Math.max(0, Math.min(volumeLevels.length - 1, index))];
    }

    // 0-25%, 26-50%, 51-75%, 76-100%.
    function forWifiSignal(strength) {
        const index = Math.ceil(strength * 100 / 25) - 1;

        return wifiStrength[Math.max(0, Math.min(wifiStrength.length - 1, index))];
    }
}

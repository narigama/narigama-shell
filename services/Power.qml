pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.UPower
import qs.config

// Laptop battery (UPower) and power profiles (power-profiles-daemon), with a warning as the charge
// runs low.
Singleton {
    id: root

    readonly property bool hasBattery: UPower.devices.values.some(d => d.isLaptopBattery)
    // All batteries combined.
    readonly property UPowerDevice battery: UPower.displayDevice
    // 0..1
    readonly property real level: battery?.percentage ?? 0
    readonly property bool plugged: !UPower.onBattery
    readonly property bool charging: battery?.state === UPowerDeviceState.Charging
    readonly property bool low: !plugged && level <= lowLevel

    readonly property real lowLevel: 0.15
    readonly property real criticalLevel: 0.05
    // The lowest threshold already warned about this discharge, so each warns once.
    property real warnedAt: 1

    readonly property bool hasProfiles: Tools.has("powerprofilesctl")
    readonly property var profiles: [[PowerProfile.PowerSaver, "Power saver", Icons.leaf], [PowerProfile.Balanced, "Balanced", Icons.scaleBalance], [PowerProfile.Performance, "Performance", Icons.speedometer]]

    // e.g. "1h 25m"
    function formatDuration(seconds) {
        const minutes = Math.round(seconds / 60);

        return minutes >= 60 ? Math.floor(minutes / 60) + "h " + minutes % 60 + "m" : minutes + "m";
    }

    readonly property string status: {
        if (!battery)
            return "";

        if (charging)
            return battery.timeToFull > 0 ? formatDuration(battery.timeToFull) + " until full" : "Charging";

        if (plugged)
            return battery.state === UPowerDeviceState.FullyCharged ? "Fully charged" : "Plugged in, not charging";

        return battery.timeToEmpty > 0 ? formatDuration(battery.timeToEmpty) + " remaining" : "On battery";
    }

    function warn(title, critical) {
        const body = Math.round(level * 100) + "% remaining";

        if (Tools.has("notify-send"))
            Quickshell.execDetached(["notify-send", "-a", "Battery", "-u", critical ? "critical" : "normal", "-i", "battery-caution", title, body]);
        else
            Osd.show(Icons.batteryAlert, title + " · " + body, level, Theme.red);
    }

    onLevelChanged: {
        if (!hasBattery || plugged)
            return;

        if (level <= criticalLevel && warnedAt > criticalLevel) {
            warnedAt = criticalLevel;
            warn("Battery critically low", true);
        } else if (level <= lowLevel && warnedAt > lowLevel) {
            warnedAt = lowLevel;
            warn("Battery low", false);
        }
    }

    onPluggedChanged: {
        if (plugged)
            warnedAt = 1;
    }
}

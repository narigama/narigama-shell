import QtQuick
import QtQuick.Layouts
import Quickshell.Services.UPower
import qs.components
import qs.config
import qs.services

ColumnLayout {
    id: root

    readonly property UPowerDevice battery: Power.battery

    width: 340
    spacing: 12

    ColumnLayout {
        Layout.fillWidth: true
        spacing: 4

        RowLayout {
            Layout.fillWidth: true

            RollingText {
                Layout.fillWidth: true
                text: Power.status
            }

            RollingText {
                text: Math.round(Power.level * 100) + "%"
                color: Power.low ? Theme.red : Theme.green
                bold: true
            }
        }

        Meter {
            Layout.fillWidth: true
            value: Power.level
            accent: Power.low ? Theme.red : Power.level <= 0.3 ? Theme.yellow : Theme.green
        }

        StyledText {
            visible: text !== ""
            text: {
                const parts = [];

                if (root.battery && root.battery.changeRate !== 0)
                    parts.push(Math.abs(root.battery.changeRate).toFixed(1) + " W");

                if (root.battery && root.battery.energyCapacity > 0)
                    parts.push(root.battery.energy.toFixed(1) + " of " + root.battery.energyCapacity.toFixed(1) + " Wh");

                // Per battery, so not on the combined display device.
                const health = UPower.devices.values.find(d => d.isLaptopBattery && d.healthSupported);

                if (health)
                    parts.push(Math.round(health.healthPercentage) + "% health");

                return parts.join(" · ");
            }
            color: Theme.fgSubtle
            font.pixelSize: Theme.fontSize - 2
        }
    }

    SectionHeader {
        text: "Power profile"
    }

    RowLayout {
        visible: Power.hasProfiles
        Layout.fillWidth: true
        spacing: 4

        Repeater {
            // Touching PowerProfiles without the daemon only logs DBus warnings.
            model: !Power.hasProfiles ? [] : Power.profiles.filter(p => p[0] !== PowerProfile.Performance || PowerProfiles.hasPerformanceProfile)

            delegate: IconButton {
                required property var modelData

                Layout.fillWidth: true
                icon: modelData[2]
                text: modelData[1]
                implicitHeight: 30
                active: PowerProfiles.profile === modelData[0]
                background: Theme.surface
                onClicked: PowerProfiles.profile = modelData[0]
            }
        }
    }

    StyledText {
        visible: Power.hasProfiles && PowerProfiles.degradationReason !== PerformanceDegradationReason.None
        text: "Performance limited: " + PerformanceDegradationReason.toString(PowerProfiles.degradationReason)
        color: Theme.yellow
        font.pixelSize: Theme.fontSize - 2
    }

    StyledText {
        visible: !Power.hasProfiles
        Layout.fillWidth: true
        text: Tools.hint("powerProfiles")
        color: Theme.fgMuted
        wrapMode: Text.Wrap
    }
}

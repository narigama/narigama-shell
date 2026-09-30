import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import qs.components
import qs.config
import qs.services

ColumnLayout {
    id: root

    width: 400
    spacing: 8

    SectionHeader {
        text: Notifications.count + " notifications"

        StyledText {
            anchors.verticalCenter: parent.verticalCenter
            text: Notifications.dnd ? Icons.bellOff : Icons.bell
            font.family: Theme.iconFontFamily
            color: Notifications.dnd ? Theme.fgMuted : Theme.green
            font.pixelSize: Theme.iconSize - 4
        }

        // On means popups are shown; off is do-not-disturb.
        Toggle {
            anchors.verticalCenter: parent.verticalCenter
            checked: !Notifications.dnd
            accent: Theme.green
            onToggled: Notifications.setDnd(!Notifications.dnd)
        }

        IconButton {
            icon: Icons.deleteSweep
            text: "Clear all"
            iconSize: Theme.fontSize + 2
            implicitHeight: 24
            foreground: Theme.red
            enabled: Notifications.count > 0
            onClicked: Notifications.clearAll()
        }
    }

    StyledText {
        visible: Notifications.count === 0
        text: "All caught up"
        color: Theme.fgMuted
    }

    // Group headers, each followed by its notifications when expanded. ids let ScriptModel keep
    // existing rows (and the scroll position) when notifications arrive.
    readonly property var rows: {
        const out = [];

        for (const group of Notifications.groups) {
            const expanded = Notifications.expandedApps.includes(group.app);

            // Count and state in the id so a changed header is rebuilt rather than kept stale.
            out.push({
                "id": ["group", group.app, group.entries.length, expanded].join(":"),
                "group": group,
                "expanded": expanded
            });

            if (expanded)
                group.entries.forEach(e => out.push({
                        "id": e.key,
                        "entry": e
                    }));
        }

        return out;
    }

    component GroupHeader: Rectangle {
        id: header

        required property var group
        required property bool expanded
        readonly property bool muted: Notifications.isMuted(group.app)

        implicitHeight: 44
        color: headerMouse.containsMouse ? Theme.elevated : Theme.surface

        MouseArea {
            id: headerMouse

            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: Notifications.toggleExpanded(header.group.app)
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 10
            anchors.rightMargin: 6
            spacing: 10

            Item {
                implicitWidth: 24
                implicitHeight: 24

                IconImage {
                    anchors.fill: parent
                    visible: header.group.icon !== ""
                    implicitSize: 24
                    source: header.group.icon
                }

                StyledText {
                    anchors.centerIn: parent
                    visible: header.group.icon === ""
                    text: Icons.application
                    font.family: Theme.iconFontFamily
                    font.pixelSize: 22
                    color: Theme.fgMuted
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 0

                StyledText {
                    Layout.fillWidth: true
                    text: header.group.app + "  ·  " + header.group.entries.length
                    font.bold: true
                }

                StyledText {
                    Layout.fillWidth: true
                    visible: !header.expanded
                    text: header.group.entries[0].summary
                    color: Theme.fgMuted
                    font.pixelSize: Theme.fontSize - 2
                }
            }

            IconButton {
                icon: header.muted ? Icons.bellOff : Icons.bell
                iconSize: Theme.fontSize + 2
                implicitHeight: 28
                foreground: header.muted ? Theme.red : Theme.fgMuted
                onClicked: Notifications.setMuted(header.group.app, !header.muted)
            }

            IconButton {
                icon: Icons.close
                iconSize: Theme.fontSize + 2
                implicitHeight: 28
                foreground: Theme.fgMuted
                onClicked: Notifications.clearApp(header.group.app)
            }

            StyledText {
                text: header.expanded ? Icons.chevronDown : Icons.chevronRight
                font.family: Theme.iconFontFamily
                color: Theme.fgMuted
            }
        }
    }

    // Wrapped so WheelScroll can sit beside the ListView rather than on its content item.
    Item {
        Layout.fillWidth: true
        Layout.preferredHeight: Math.min(history.contentHeight, 560)
        visible: Notifications.count > 0

        WheelScroll {
            flickable: history
        }

        ListView {
            id: history

            anchors.fill: parent
            clip: true
            spacing: 6
            interactive: false

            model: ScriptModel {
                values: root.rows
                objectProp: "id"
            }

            delegate: Loader {
                id: row

                required property var modelData

                width: ListView.view.width
                sourceComponent: modelData.group ? headerComponent : cardComponent

                Component {
                    id: headerComponent

                    GroupHeader {
                        group: row.modelData.group
                        expanded: row.modelData.expanded
                    }
                }

                Component {
                    id: cardComponent

                    NotificationCard {
                        entry: row.modelData.entry
                    }
                }
            }
        }
    }
}

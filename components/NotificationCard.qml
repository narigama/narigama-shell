import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import qs.config
import qs.services

// One notification history entry, as shown in popups and the notifications dropdown.
Rectangle {
    id: root

    required property var entry
    readonly property bool critical: entry.urgency === 2
    readonly property bool live: Notifications.live[entry.key] !== undefined
    readonly property string iconSource: {
        if (entry.image)
            return entry.image.startsWith("/") ? "file://" + entry.image : entry.image;

        return Notifications.appIconSource(entry.appIcon);
    }
    readonly property bool hovered: hover.hovered

    function timeAgo(time) {
        const minutes = Math.floor((Date.now() - time) / 60000);

        if (minutes < 1)
            return "now";

        if (minutes < 60)
            return minutes + "m";

        if (minutes < 1440)
            return Math.floor(minutes / 60) + "h";

        return Qt.formatDate(new Date(time), "d MMM");
    }

    implicitHeight: layout.implicitHeight + 24
    color: Theme.surface
    border.color: critical ? Theme.red : Theme.elevated
    border.width: 1

    HoverHandler {
        id: hover
    }

    // Clicking the body runs the sender's default action, like most daemons.
    TapHandler {
        onTapped: {
            if (root.entry.actions.some(a => a.identifier === "default"))
                Notifications.invoke(root.entry.key, "default");
        }
    }

    RowLayout {
        id: layout

        anchors.fill: parent
        anchors.margins: 12
        spacing: 12

        IconImage {
            Layout.alignment: Qt.AlignTop
            visible: root.iconSource !== ""
            implicitSize: 36
            source: root.iconSource
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 4

            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                StyledText {
                    Layout.fillWidth: true
                    text: root.entry.appName || "Notification"
                    color: Theme.fgMuted
                    font.pixelSize: Theme.fontSize - 2
                    font.bold: true
                }

                StyledText {
                    text: root.timeAgo(root.entry.time)
                    color: Theme.fgSubtle
                    font.pixelSize: Theme.fontSize - 2
                }

                IconButton {
                    icon: Icons.close
                    iconSize: Theme.fontSize
                    implicitHeight: 20
                    foreground: Theme.fgMuted
                    onClicked: Notifications.remove(root.entry.key)
                }
            }

            StyledText {
                Layout.fillWidth: true
                text: root.entry.summary
                color: root.critical ? Theme.red : Theme.green
                font.bold: true
                wrapMode: Text.Wrap
                maximumLineCount: 2
            }

            StyledText {
                Layout.fillWidth: true
                visible: text !== ""
                text: root.entry.body
                textFormat: Text.StyledText
                wrapMode: Text.Wrap
                maximumLineCount: 4
                font.pixelSize: Theme.fontSize - 1
            }

            Flow {
                Layout.fillWidth: true
                visible: root.live && actionsRepeater.count > 0
                spacing: 4

                Repeater {
                    id: actionsRepeater

                    model: root.entry.actions.filter(a => a.identifier !== "default" && a.text !== "")

                    delegate: IconButton {
                        required property var modelData

                        text: modelData.text
                        foreground: Theme.primary
                        implicitHeight: 26
                        background: Theme.elevated
                        onClicked: Notifications.invoke(root.entry.key, modelData.identifier)
                    }
                }
            }
        }
    }
}

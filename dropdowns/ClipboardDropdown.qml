import QtQuick
import QtQuick.Layouts
import qs.components
import qs.config
import qs.services

ColumnLayout {
    id: root

    readonly property var filtered: search.text === "" ? Clipboard.entries : Clipboard.entries.filter(e => e.text.toLowerCase().includes(search.text.toLowerCase()))

    width: 440
    spacing: 4

    Component.onCompleted: Clipboard.refresh()

    RowLayout {
        Layout.fillWidth: true
        spacing: 8

        TextField {
            id: search

            Layout.fillWidth: true
            placeholder: "Search"
            onAccepted: {
                if (root.filtered.length > 0) {
                    Clipboard.copy(root.filtered[0]);
                    Dropdowns.close();
                }
            }
        }

        // Wiping is irreversible, so it takes a second click within a few seconds.
        IconButton {
            id: clearButton

            property bool armed: false

            icon: Icons.deleteSweep
            text: armed ? "Click again to clear" : "Clear"
            foreground: Theme.red
            active: armed
            enabled: Clipboard.entries.length > 0
            onClicked: {
                if (!armed) {
                    armed = true;
                    disarm.restart();
                    return;
                }

                armed = false;
                Clipboard.clear();
            }

            Timer {
                id: disarm

                interval: 3000
                onTriggered: clearButton.armed = false
            }
        }
    }

    StyledText {
        visible: !Clipboard.watching
        Layout.fillWidth: true
        text: "Nothing is recording history. Start it from your compositor's autostart: wl-paste --watch cliphist store"
        color: Theme.yellow
        font.pixelSize: Theme.fontSize - 2
        wrapMode: Text.Wrap
    }

    StyledText {
        visible: root.filtered.length === 0
        Layout.topMargin: 8
        text: Clipboard.entries.length === 0 ? "History is empty" : "No matches"
        color: Theme.fgMuted
    }

    Repeater {
        model: root.filtered.slice(0, 30)

        delegate: ListRow {
            id: entryRow

            required property var modelData

            implicitHeight: 36
            icon: modelData.image ? Icons.image : ""
            iconColor: Theme.fgMuted
            title: modelData.text.replace(/\s+/g, " ").trim()
            onClicked: {
                Clipboard.copy(modelData);
                Dropdowns.close();
            }

            IconButton {
                icon: Icons.close
                iconSize: Theme.fontSize
                implicitHeight: 24
                foreground: Theme.fgMuted
                onClicked: Clipboard.remove(entryRow.modelData)
            }
        }
    }
}

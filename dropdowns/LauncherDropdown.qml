import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import qs.components
import qs.config
import qs.services

// Search field and results. Up/Down (or Ctrl+N/P, Tab) move the selection, Enter runs it.
// Prefixes: `>` runs a command, `:` searches clipboard history; sums are calculated.
ColumnLayout {
    id: root

    property var results: Launcher.search("")
    property int selected: 0
    readonly property int rowHeight: 48
    readonly property int visibleRows: 8

    function run(index) {
        const result = results[index];

        if (!result)
            return;

        Dropdowns.close();
        result.run();
    }

    function move(delta) {
        if (results.length === 0)
            return;

        selected = (selected + delta + results.length) % results.length;
        list.positionViewAtIndex(selected, ListView.Contain);
    }

    width: 560
    spacing: 8

    Component.onCompleted: Clipboard.refresh()

    // The dropdown panel takes focus as it opens, after this is created; take it back once settled.
    Timer {
        interval: 50
        running: true
        onTriggered: search.focusInput()
    }

    TextField {
        id: search

        Layout.fillWidth: true
        implicitHeight: 40
        placeholder: "Search apps and windows   > command   : clipboard   = sum"
        onTextChanged: {
            root.results = Launcher.search(text);
            root.selected = 0;
            list.positionViewAtBeginning();
        }
        onAccepted: root.run(root.selected)

        Keys.onUpPressed: root.move(-1)
        Keys.onDownPressed: root.move(1)
        Keys.onTabPressed: root.move(1)
        Keys.onBacktabPressed: root.move(-1)
        Keys.onPressed: event => {
            if (event.modifiers & Qt.ControlModifier && (event.key === Qt.Key_N || event.key === Qt.Key_J)) {
                root.move(1);
                event.accepted = true;
            } else if (event.modifiers & Qt.ControlModifier && (event.key === Qt.Key_P || event.key === Qt.Key_K)) {
                root.move(-1);
                event.accepted = true;
            }
        }
    }

    StyledText {
        visible: root.results.length === 0
        Layout.topMargin: 4
        text: search.text.trim().startsWith(":") && !Tools.available("clipboard") ? Tools.hint("clipboard") : "No matches"
        color: Theme.fgMuted
    }

    Item {
        Layout.fillWidth: true
        implicitHeight: list.height

        // The dropdown's own scroll handler sits behind this whole view and scrolls the outer area.
        WheelScroll {
            flickable: list
        }

        ListView {
            id: list

            width: parent.width
            height: Math.min(root.results.length, root.visibleRows) * root.rowHeight
            model: root.results
            clip: true
            interactive: false
            boundsBehavior: Flickable.StopAtBounds

            delegate: Rectangle {
                id: row

                required property var modelData
                required property int index
                readonly property bool current: index === root.selected

                width: list.width
                height: root.rowHeight
                color: current ? Theme.elevated : rowMouse.containsMouse ? Theme.surface : "transparent"

                Rectangle {
                    visible: row.current
                    width: 3
                    height: parent.height
                    color: Theme.primary
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    spacing: 12

                    // Theme icon when there is one (checked, so a missing one isn't drawn as a placeholder), else the glyph.
                    Item {
                        readonly property string iconSource: {
                            const icon = row.modelData.icon;

                            if (!icon)
                                return "";

                            return icon.startsWith("/") ? "file://" + icon : Quickshell.iconPath(icon, true);
                        }

                        Layout.preferredWidth: 28
                        Layout.preferredHeight: 28

                        IconImage {
                            anchors.fill: parent
                            visible: parent.iconSource !== ""
                            source: parent.iconSource
                            asynchronous: true
                        }

                        StyledText {
                            anchors.centerIn: parent
                            visible: parent.iconSource === ""
                            text: row.modelData.glyph ?? ""
                            color: row.current ? Theme.primary : Theme.fgMuted
                            font.family: Theme.iconFontFamily
                            font.pixelSize: 22
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 0

                        StyledText {
                            Layout.fillWidth: true
                            text: row.modelData.title
                            color: row.current ? Theme.primary : Theme.fg
                            font.bold: row.current
                        }

                        StyledText {
                            visible: text !== ""
                            Layout.fillWidth: true
                            text: row.modelData.subtitle ?? ""
                            color: Theme.fgSubtle
                            font.pixelSize: Theme.fontSize - 3
                        }
                    }

                    StyledText {
                        text: ({
                                "app": "",
                                "window": "window",
                                "calculator": "copy",
                                "command": "run",
                                "clipboard": "paste"
                            })[row.modelData.kind] ?? ""
                        color: Theme.fgSubtle
                        font.pixelSize: Theme.fontSize - 3
                    }
                }

                MouseArea {
                    id: rowMouse

                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.run(row.index)
                }
            }
        }
    }
}

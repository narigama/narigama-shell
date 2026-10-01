import QtQuick
import QtQuick.Layouts
import qs.config
import qs.services

// Drag-and-drop editor for the bar's module order: Left, Centre and Right groups, each module
// with a drag handle and a show/hide switch. Dropping writes ShellState.barLayout.
ColumnLayout {
    id: root

    readonly property var groups: [["left", "Left"], ["center", "Centre"], ["right", "Right"]]
    readonly property int rowHeight: 30
    // Flattened rows: a header per group, then that group's modules.
    readonly property var rows: {
        const out = [];

        for (const [group, label] of groups) {
            out.push({
                "header": true,
                "group": group,
                "label": label
            });

            for (const name of ShellState.layout[group])
                out.push({
                    "header": false,
                    "group": group,
                    "name": name
                });
        }

        return out;
    }

    // The module being dragged ("" when idle) and the pointer's y within the list.
    property string dragging: ""
    property real dragY: 0
    readonly property var dropSlot: dragging === "" ? null : slotAt(dragY)

    // Where a drop at `y` lands: the group of the nearest header above, and the index among that
    // group's other modules, plus the y to draw the insertion line at.
    function slotAt(y) {
        let group = "left";
        let index = 0;
        let lineY = 0;

        for (let i = 0; i < repeater.count; i++) {
            const item = repeater.itemAt(i);
            const row = rows[i];

            if (!item)
                continue;

            if (row.header) {
                if (item.y > y && i > 0)
                    break;

                group = row.group;
                index = 0;
                lineY = item.y + item.height;
                continue;
            }

            if (row.name === dragging)
                continue;

            if (item.y + item.height / 2 < y) {
                index++;
                lineY = item.y + item.height;
            }
        }

        return {
            "group": group,
            "index": index,
            "y": lineY
        };
    }

    spacing: 0

    Item {
        Layout.fillWidth: true
        implicitHeight: list.implicitHeight

        Column {
            id: list

            width: parent.width

            Repeater {
                id: repeater

                model: root.rows

                delegate: Item {
                    id: row

                    required property var modelData
                    readonly property bool isDragged: !modelData.header && modelData.name === root.dragging
                    // Install hint when the module's tools are missing.
                    readonly property string hint: modelData.header ? "" : Tools.hint(modelData.name)

                    width: list.width
                    height: modelData.header ? 26 : hint !== "" ? root.rowHeight + 16 : root.rowHeight

                    StyledText {
                        visible: row.modelData.header
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 4
                        text: row.modelData.label ?? ""
                        color: Theme.fgMuted
                        font.pixelSize: Theme.fontSize - 2
                        font.bold: true
                    }

                    Rectangle {
                        id: body

                        visible: !row.modelData.header
                        width: parent.width
                        height: parent.height
                        // While dragged, the row follows the pointer above the rest.
                        y: row.isDragged ? root.dragY - row.y - height / 2 : 0
                        z: row.isDragged ? 10 : 0
                        color: row.isDragged ? Theme.elevated : handleMouse.containsMouse ? Theme.surface : "transparent"

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 4
                            anchors.rightMargin: 4
                            spacing: 8

                            StyledText {
                                text: Icons.dragHandle
                                font.family: Theme.iconFontFamily
                                color: Theme.fgMuted

                                MouseArea {
                                    id: handleMouse

                                    anchors.fill: parent
                                    anchors.margins: -6
                                    hoverEnabled: true
                                    cursorShape: root.dragging === "" ? Qt.OpenHandCursor : Qt.ClosedHandCursor
                                    preventStealing: true

                                    onPressed: mouse => {
                                        root.dragY = mapToItem(list, mouse.x, mouse.y).y;
                                        root.dragging = row.modelData.name;
                                    }

                                    onPositionChanged: mouse => {
                                        if (root.dragging !== "")
                                            root.dragY = mapToItem(list, mouse.x, mouse.y).y;
                                    }

                                    onReleased: {
                                        const slot = root.dropSlot;
                                        const name = root.dragging;

                                        root.dragging = "";

                                        if (slot)
                                            ShellState.moveModule(name, slot.group, slot.index);
                                    }
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 0

                                StyledText {
                                    Layout.fillWidth: true
                                    text: row.modelData.header ? "" : ShellState.moduleLabel(row.modelData.name)
                                    color: row.hint !== "" ? Theme.fgMuted : Theme.fg
                                }

                                StyledText {
                                    visible: row.hint !== ""
                                    Layout.fillWidth: true
                                    text: row.hint
                                    color: Theme.yellow
                                    font.pixelSize: Theme.fontSize - 3
                                }
                            }

                            Toggle {
                                visible: !row.modelData.header && row.hint === "" && !ShellState.unhideableModules.includes(row.modelData.name)
                                checked: !row.modelData.header && ShellState.moduleVisible(row.modelData.name)
                                onToggled: ShellState.setModuleVisible(row.modelData.name, !checked)
                            }
                        }
                    }
                }
            }
        }

        // Insertion line for the current drop position.
        Rectangle {
            visible: root.dropSlot !== null
            y: (root.dropSlot?.y ?? 0) - 1
            width: parent.width
            height: 2
            color: Theme.primary
        }
    }
}

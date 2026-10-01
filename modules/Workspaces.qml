import QtQuick
import Quickshell
import qs.config
import qs.services

// Workspace buttons with one highlight block that slides to the active workspace.
Item {
    id: root

    required property ShellScreen screen
    property Item activeItem: null

    implicitWidth: row.implicitWidth
    implicitHeight: Theme.barHeight

    Component.onCompleted: Dropdowns.register("workspaces", root, screen)

    Rectangle {
        visible: root.activeItem !== null
        x: root.activeItem?.x ?? 0
        width: root.activeItem?.width ?? 0
        height: parent.height
        color: Theme.primary

        Behavior on x {
            NumberAnimation {
                duration: 200
                easing.type: Easing.OutCubic
            }
        }

        Behavior on width {
            NumberAnimation {
                duration: 200
                easing.type: Easing.OutCubic
            }
        }
    }

    Row {
        id: row

        height: parent.height

        Repeater {
            // Diffed, so existing buttons keep their position for the highlight to slide from.
            model: ScriptModel {
                values: Compositor.workspacesFor(root.screen)
            }

            delegate: Item {
                id: workspace

                required property var modelData
                readonly property bool active: Compositor.isActive(modelData)
                readonly property bool occupied: Compositor.isOccupied(modelData)
                readonly property bool urgent: Compositor.isUrgent(modelData) && !active

                implicitWidth: Math.max(Theme.workspaceMinWidth, label.implicitWidth + 2 * Theme.workspacePadding)
                implicitHeight: Theme.barHeight

                onActiveChanged: {
                    if (active)
                        root.activeItem = workspace;
                }

                Component.onCompleted: {
                    if (active)
                        root.activeItem = workspace;
                }

                Component.onDestruction: {
                    if (root.activeItem === workspace)
                        root.activeItem = null;
                }

                Rectangle {
                    id: urgentFlash

                    anchors.fill: parent
                    visible: workspace.urgent
                    color: Theme.red

                    SequentialAnimation on opacity {
                        running: workspace.urgent
                        loops: Animation.Infinite

                        NumberAnimation {
                            from: 1
                            to: 0.35
                            duration: 700
                            easing.type: Easing.InOutSine
                        }

                        NumberAnimation {
                            from: 0.35
                            to: 1
                            duration: 700
                            easing.type: Easing.InOutSine
                        }
                    }
                }

                Text {
                    id: label

                    anchors.centerIn: parent
                    text: WorkspaceLabels.label(Compositor.number(workspace.modelData), Compositor.name(workspace.modelData))
                    color: workspace.active || workspace.urgent ? Theme.surface : workspace.occupied ? Theme.fgMuted : Theme.fgSubtle
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize
                    font.bold: true

                    Behavior on color {
                        ColorAnimation {
                            duration: 200
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    cursorShape: Qt.PointingHandCursor
                    onClicked: mouse => {
                        if (mouse.button === Qt.RightButton)
                            Dropdowns.toggle("workspaces", root, root.screen);
                        else
                            Compositor.activate(workspace.modelData);
                    }
                }
            }
        }
    }
}

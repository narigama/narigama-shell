import QtQuick
import Quickshell
import Quickshell.Hyprland
import qs.config
import qs.services

// Workspace buttons with one highlight block that slides to the active workspace.
Item {
    id: root

    required property ShellScreen screen
    readonly property HyprlandMonitor monitor: Hyprland.monitorFor(screen)
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
                values: Hyprland.workspaces.values.filter(w => w.monitor === root.monitor).sort((a, b) => a.id - b.id)
            }

            delegate: Item {
                id: workspace

                required property HyprlandWorkspace modelData
                readonly property bool active: modelData.active
                readonly property bool occupied: modelData.toplevels.values.length > 0
                // Hyprland marks a workspace urgent when a window asks for attention (bell,
                // xdg-activation); it clears once the workspace is visited.
                readonly property bool urgent: modelData.urgent && !active

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
                    text: WorkspaceLabels.label(workspace.modelData)
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
                            workspace.modelData.activate();
                    }
                }
            }
        }
    }
}

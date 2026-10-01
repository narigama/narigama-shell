import QtQuick
import QtQuick.Layouts
import qs.components
import qs.config
import qs.services

ColumnLayout {
    id: root

    width: 380
    spacing: 4

    Component.onCompleted: Compositor.refreshWindows()

    Repeater {
        model: Compositor.workspaces

        delegate: ColumnLayout {
            id: workspaceItem

            required property var modelData
            required property int index
            readonly property var windows: Compositor.windowsFor(modelData)

            Layout.fillWidth: true
            Layout.topMargin: index === 0 ? 0 : 8
            spacing: 0

            ListRow {
                icon: Icons.monitor
                iconColor: Compositor.isActive(workspaceItem.modelData) ? Theme.primary : Theme.fgMuted
                title: "Workspace " + WorkspaceLabels.label(Compositor.number(workspaceItem.modelData), Compositor.name(workspaceItem.modelData))
                subtitle: Compositor.screenName(workspaceItem.modelData) + (Compositor.hasWindowLists ? " · " + workspaceItem.windows.length + " windows" : "")
                highlighted: Compositor.isFocused(workspaceItem.modelData)
                onClicked: Compositor.activate(workspaceItem.modelData)
            }

            Repeater {
                model: workspaceItem.windows

                delegate: ListRow {
                    required property var modelData

                    Layout.leftMargin: 24
                    title: modelData.title
                    subtitle: modelData.subtitle
                    highlighted: modelData.focused
                    onClicked: modelData.focus()
                }
            }
        }
    }
}

import QtQuick
import QtQuick.Layouts
import qs.components
import qs.config
import qs.services

ColumnLayout {
    width: 340
    spacing: 8

    StyledText {
        visible: !Privacy.active
        text: "Nothing is using your mic, camera or screen"
        color: Theme.fgMuted
    }

    Repeater {
        model: [["mic", "Microphone", Icons.microphone, Privacy.micApps], ["camera", "Camera", Icons.camera, Privacy.cameraApps], ["screen", "Screen sharing", Icons.screenShare, Privacy.screenApps]].filter(k => k[3].length > 0)

        delegate: ColumnLayout {
            id: group

            required property var modelData

            Layout.fillWidth: true
            spacing: 0

            SectionHeader {
                text: group.modelData[1]
            }

            Repeater {
                model: group.modelData[3]

                delegate: ListRow {
                    required property string modelData

                    icon: group.modelData[2]
                    iconColor: Theme.red
                    title: modelData
                    clickable: false
                }
            }
        }
    }
}

import QtQuick
import QtQuick.Layouts
import qs.components
import qs.config
import qs.services

ColumnLayout {
    id: root

    readonly property string screenName: Dropdowns.screen?.name ?? ""

    width: 320
    spacing: 4

    function run(action) {
        Dropdowns.close();
        action();
    }

    SectionHeader {
        text: "Screenshot"
    }

    ListRow {
        icon: Icons.crop
        title: "Region"
        onClicked: root.run(() => Capture.screenshot(""))
    }

    ListRow {
        icon: Icons.monitor
        title: "Screen"
        subtitle: root.screenName
        onClicked: root.run(() => Capture.screenshot(root.screenName))
    }

    RowLayout {
        Layout.fillWidth: true
        Layout.leftMargin: 12
        Layout.rightMargin: 8

        StyledText {
            Layout.fillWidth: true
            text: "Annotate in satty"
            color: Theme.fgMuted
        }

        StyledText {
            visible: !Tools.has("satty")
            text: Tools.optionalHint("satty")
            color: Theme.yellow
            font.pixelSize: Theme.fontSize - 3
        }

        Toggle {
            visible: Tools.has("satty")
            checked: ShellState.captureAnnotate
            onToggled: ShellState.captureAnnotate = !ShellState.captureAnnotate
        }
    }

    SectionHeader {
        Layout.topMargin: 8
        text: "Record"
    }

    StyledText {
        visible: !Tools.has("wf-recorder")
        Layout.leftMargin: 12
        text: Tools.optionalHint("wf-recorder")
        color: Theme.yellow
        font.pixelSize: Theme.fontSize - 3
    }

    ListRow {
        visible: Tools.has("wf-recorder")
        icon: Icons.crop
        title: "Region"
        onClicked: root.run(() => Capture.startRecording(""))
    }

    ListRow {
        visible: Tools.has("wf-recorder")
        icon: Icons.video
        title: "Screen"
        subtitle: root.screenName
        onClicked: root.run(() => Capture.startRecording(root.screenName))
    }

    RowLayout {
        visible: Tools.has("wf-recorder")
        Layout.fillWidth: true
        Layout.leftMargin: 12
        Layout.rightMargin: 8

        StyledText {
            Layout.fillWidth: true
            text: "Record audio"
            color: Theme.fgMuted
        }

        Toggle {
            checked: ShellState.captureAudio
            onToggled: ShellState.captureAudio = !ShellState.captureAudio
        }
    }

    StyledText {
        Layout.topMargin: 4
        Layout.fillWidth: true
        text: "Click the bar button again to stop recording"
        color: Theme.fgSubtle
        font.pixelSize: Theme.fontSize - 2
    }
}

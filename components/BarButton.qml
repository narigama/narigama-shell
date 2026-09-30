import QtQuick
import Quickshell
import qs.config
import qs.services

// Transparent-background button with a coloured icon and label.
Item {
    id: root

    property string icon
    property string label
    property color color: Theme.primary
    property color iconColor: color
    property int iconSize: Theme.iconSize
    property bool labelShow: true
    // Dropdown names (see modules/DropdownHost.qml) opened by left/right click.
    property string leftDropdown: ""
    property string rightDropdown: ""
    // Pages reached from within this button's dropdown (e.g. settings from the system menu); registered
    // so `ipc call dropdown toggle <name>` hangs them from this button.
    property var relatedDropdowns: []
    readonly property bool dropdownOpen: Dropdowns.current !== "" && Dropdowns.anchorItem === root

    signal leftClicked
    signal rightClicked
    signal middleClicked
    signal scrolledUp
    signal scrolledDown

    implicitWidth: row.implicitWidth + 2 * Theme.buttonPadding
    implicitHeight: Theme.barHeight

    // The window only knows its screen once mapped, so register when it arrives.
    readonly property ShellScreen barScreen: QsWindow.window?.screen ?? null

    onBarScreenChanged: {
        Dropdowns.register(leftDropdown, root, barScreen);
        Dropdowns.register(rightDropdown, root, barScreen);

        for (const name of relatedDropdowns)
            Dropdowns.register(name, root, barScreen);
    }

    onLeftClicked: {
        if (leftDropdown !== "")
            Dropdowns.toggle(leftDropdown, root, QsWindow.window.screen);
    }

    onRightClicked: {
        if (rightDropdown !== "")
            Dropdowns.toggle(rightDropdown, root, QsWindow.window.screen);
    }

    Rectangle {
        anchors.fill: parent
        color: Theme.elevated
        visible: root.dropdownOpen || mouse.containsMouse
    }

    Row {
        id: row

        anchors.centerIn: parent
        spacing: Theme.iconGap

        Text {
            anchors.verticalCenter: parent.verticalCenter
            visible: root.icon !== ""
            text: root.icon
            color: root.iconColor
            font.family: Theme.iconFontFamily
            font.pixelSize: root.iconSize
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            visible: root.labelShow && root.label !== ""
            text: root.label
            color: root.color
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
            font.bold: true
        }
    }

    MouseArea {
        id: mouse

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton

        onClicked: mouse => {
            if (mouse.button === Qt.LeftButton)
                root.leftClicked();
            else if (mouse.button === Qt.RightButton)
                root.rightClicked();
            else
                root.middleClicked();
        }

        onWheel: wheel => {
            if (wheel.angleDelta.y > 0)
                root.scrolledUp();
            else if (wheel.angleDelta.y < 0)
                root.scrolledDown();
        }
    }
}

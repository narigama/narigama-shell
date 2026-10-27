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
    property bool rollLabel: false
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
        opacity: root.dropdownOpen || mouse.containsMouse ? 1 : 0

        Behavior on opacity {
            NumberAnimation {
                duration: 180
                easing.type: Easing.OutCubic
            }
        }
    }

    property string shownIcon: ""
    property string outgoingIcon: ""

    onIconChanged: {
        if (shownIcon === "" || icon === "") {
            shownIcon = icon;
            return;
        }

        if (icon !== shownIcon) {
            outgoingIcon = shownIcon;
            shownIcon = icon;
            iconFade.restart();
        }
    }

    Component.onCompleted: shownIcon = icon

    ParallelAnimation {
        id: iconFade

        NumberAnimation {
            target: outgoingGlyph
            property: "opacity"
            from: 1
            to: 0
            duration: 180
            easing.type: Easing.OutCubic
        }

        NumberAnimation {
            target: incomingGlyph
            property: "opacity"
            from: 0
            to: 1
            duration: 180
            easing.type: Easing.OutCubic
        }
    }

    Row {
        id: row

        anchors.centerIn: parent
        spacing: Theme.iconGap

        Item {
            anchors.verticalCenter: parent.verticalCenter
            visible: root.shownIcon !== ""
            implicitWidth: Math.max(incomingGlyph.implicitWidth, iconFade.running ? outgoingGlyph.implicitWidth : 0)
            implicitHeight: incomingGlyph.implicitHeight

            Text {
                id: outgoingGlyph

                anchors.centerIn: parent
                text: root.outgoingIcon
                color: incomingGlyph.color
                font.family: Theme.iconFontFamily
                font.pixelSize: root.iconSize
                opacity: 0
            }

            Text {
                id: incomingGlyph

                anchors.centerIn: parent
                text: root.shownIcon
                color: root.iconColor
                font.family: Theme.iconFontFamily
                font.pixelSize: root.iconSize

                Behavior on color {
                    ColorAnimation {
                        duration: 180
                        easing.type: Easing.OutCubic
                    }
                }
            }
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            visible: root.labelShow && root.label !== "" && !root.rollLabel
            text: root.label
            color: root.color
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
            font.bold: true
        }

        RollingText {
            anchors.verticalCenter: parent.verticalCenter
            visible: root.labelShow && root.label !== "" && root.rollLabel
            text: root.label
            color: root.color
            bold: true
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

import QtQuick
import qs.config

// Flat square button holding a glyph, optionally with a text label.
Rectangle {
    id: root

    property string icon
    property string text
    property color foreground: Theme.fg
    property int iconSize: Theme.iconSize
    property bool active: false
    property bool enabled: true
    property color background: "transparent"
    property string shownIcon: ""
    property string outgoingIcon: ""

    signal clicked()

    implicitWidth: Math.max(implicitHeight, content.implicitWidth + 16)
    implicitHeight: 32
    color: active ? Theme.primary : mouse.containsMouse && enabled ? Theme.elevated : background
    opacity: enabled ? 1 : 0.4
    onIconChanged: {
        if (shownIcon === "" || icon === "") {
            shownIcon = icon;
            return ;
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
        id: content

        anchors.centerIn: parent
        spacing: 8

        Item {
            anchors.verticalCenter: parent.verticalCenter
            visible: root.shownIcon !== ""
            implicitWidth: Math.max(incomingGlyph.implicitWidth, iconFade.running ? outgoingGlyph.implicitWidth : 0)
            implicitHeight: incomingGlyph.implicitHeight

            StyledText {
                id: outgoingGlyph

                anchors.centerIn: parent
                text: root.outgoingIcon
                font.family: Theme.iconFontFamily
                color: incomingGlyph.color
                font.pixelSize: root.iconSize
                opacity: 0
            }

            StyledText {
                id: incomingGlyph

                anchors.centerIn: parent
                text: root.shownIcon
                font.family: Theme.iconFontFamily
                color: root.active ? Theme.surface : root.foreground
                font.pixelSize: root.iconSize

                Behavior on color {
                    ColorAnimation {
                        duration: 180
                        easing.type: Easing.OutCubic
                    }

                }

            }

        }

        RollingText {
            anchors.verticalCenter: parent.verticalCenter
            visible: root.text !== ""
            text: root.text
            color: root.active ? Theme.surface : root.foreground
            bold: true
        }

    }

    MouseArea {
        id: mouse

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: root.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: {
            if (root.enabled)
                root.clicked();

        }
    }

    Behavior on color {
        ColorAnimation {
            duration: 180
            easing.type: Easing.OutCubic
        }

    }

    Behavior on opacity {
        NumberAnimation {
            duration: 180
            easing.type: Easing.OutCubic
        }

    }

}

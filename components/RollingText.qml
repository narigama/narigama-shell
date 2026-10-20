import QtQuick
import qs.config

// Single-line text that rolls vertically when its text changes and scrolls Winamp-style when wider than its box.
Item {
    id: root

    property string text: ""
    property string trigger: text
    property int delay: 0
    property color color: Theme.fg
    property int pixelSize: Theme.fontSize
    property bool bold: false
    property int horizontalAlignment: Text.AlignLeft
    // 0 fills the assigned width; > 0 caps implicitWidth and animates width changes.
    property int maxWidth: 0

    readonly property bool overflows: incoming.implicitWidth > (maxWidth > 0 ? maxWidth : width) && width > 0
    property string shownText: ""
    property string outgoingText: ""
    property string lastTrigger: ""

    implicitWidth: maxWidth > 0 ? Math.min(incoming.implicitWidth, maxWidth) : Math.max(incoming.implicitWidth, rollAnim.running ? outgoing.implicitWidth : 0)
    implicitHeight: maxWidth > 0 ? Theme.barHeight : incoming.implicitHeight
    clip: true

    Behavior on implicitWidth {
        enabled: root.outgoingText !== ""

        NumberAnimation {
            duration: 280
            easing.type: Easing.OutCubic
        }
    }

    function alignedX(itemWidth) {
        if (overflows || horizontalAlignment === Text.AlignLeft)
            return 0;

        if (horizontalAlignment === Text.AlignRight)
            return width - itemWidth;

        return Math.round((width - itemWidth) / 2);
    }

    onTextChanged: {
        if (text === "" || shownText === "") {
            shownText = text;
            lastTrigger = trigger;
            incoming.x = Qt.binding(() => root.alignedX(incoming.implicitWidth));
            return;
        }

        if (text !== shownText)
            settleTimer.restart();
    }

    onTriggerChanged: {
        if (lastTrigger === "") {
            lastTrigger = trigger;
            return;
        }

        if (trigger !== lastTrigger && shownText !== "")
            settleTimer.restart();
    }

    Component.onCompleted: {
        shownText = text;
        lastTrigger = trigger;
    }

    // Players often emit trackTitle and trackArtist in separate ticks; coalesce into one roll.
    Timer {
        id: settleTimer

        interval: 40 + root.delay
        onTriggered: {
            if (root.text === "" || (root.text === root.shownText && root.trigger === root.lastTrigger))
                return;

            outgoing.x = incoming.x;
            root.outgoingText = root.shownText;
            root.shownText = root.text;
            root.lastTrigger = root.trigger;
            incoming.x = Qt.binding(() => root.alignedX(incoming.implicitWidth));
            rollAnim.restart();
        }
    }

    Text {
        id: outgoing

        height: parent.height
        verticalAlignment: Text.AlignVCenter
        text: x < 0 ? root.outgoingText + "      " + root.outgoingText : root.outgoingText
        color: root.color
        font.family: Theme.fontFamily
        font.pixelSize: root.pixelSize
        font.bold: root.bold
        opacity: 0
    }

    Text {
        id: incoming

        x: root.alignedX(implicitWidth)
        height: parent.height
        verticalAlignment: Text.AlignVCenter
        text: root.shownText
        color: root.color
        font.family: Theme.fontFamily
        font.pixelSize: root.pixelSize
        font.bold: root.bold
    }

    Text {
        id: clone

        anchors.left: incoming.right
        y: incoming.y
        height: parent.height
        verticalAlignment: Text.AlignVCenter
        visible: root.overflows
        opacity: incoming.opacity
        text: "      " + root.shownText
        color: root.color
        font.family: Theme.fontFamily
        font.pixelSize: root.pixelSize
        font.bold: root.bold
    }

    SequentialAnimation {
        running: root.overflows && !rollAnim.running
        loops: Animation.Infinite

        onStopped: incoming.x = Qt.binding(() => root.alignedX(incoming.implicitWidth))

        PauseAnimation {
            duration: 5000
        }

        NumberAnimation {
            target: incoming
            property: "x"
            from: 0
            to: -clone.implicitWidth
            duration: Math.max(1500, Math.round(clone.implicitWidth * 36))
        }
    }

    ParallelAnimation {
        id: rollAnim

        NumberAnimation {
            target: outgoing
            property: "y"
            from: 0
            to: -root.height
            duration: 280
            easing.type: Easing.OutCubic
        }

        NumberAnimation {
            target: outgoing
            property: "opacity"
            from: 1
            to: 0
            duration: 220
            easing.type: Easing.OutCubic
        }

        NumberAnimation {
            target: incoming
            property: "y"
            from: root.height
            to: 0
            duration: 280
            easing.type: Easing.OutCubic
        }

        NumberAnimation {
            target: incoming
            property: "opacity"
            from: 0
            to: 1
            duration: 260
            easing.type: Easing.OutCubic
        }
    }
}

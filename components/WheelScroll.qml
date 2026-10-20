import QtQuick

// Fixed step per wheel notch for a Flickable, placed behind its content so controls that use
// the wheel themselves (sliders) still get it first. A WheelHandler never received events here.
MouseArea {
    id: root

    required property Flickable flickable
    readonly property real pixelsPerNotch: 160
    property real targetY: 0

    anchors.fill: flickable
    z: -1
    acceptedButtons: Qt.NoButton

    NumberAnimation {
        id: anim

        target: root.flickable
        property: "contentY"
        to: root.targetY
        duration: 180
        easing.type: Easing.OutCubic
    }

    onWheel: wheel => {
        // QtWayland populates pixelDelta (~15px) even for discrete mouse wheels, so use angleDelta (120 per notch).
        const delta = wheel.angleDelta.y !== 0 ? wheel.angleDelta.y / 120 * pixelsPerNotch : wheel.pixelDelta.y * 3;
        const max = Math.max(0, flickable.contentHeight - flickable.height);
        const base = anim.running ? targetY : flickable.contentY;

        targetY = Math.max(0, Math.min(max, base - delta));
        anim.restart();
    }
}

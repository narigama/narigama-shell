import QtQuick

// Fixed step per wheel notch for a Flickable, placed behind its content so controls that use
// the wheel themselves (sliders) still get it first. A WheelHandler never received events here.
MouseArea {
    id: root

    required property Flickable flickable
    readonly property real pixelsPerNotch: 100

    anchors.fill: flickable
    z: -1
    acceptedButtons: Qt.NoButton

    onWheel: wheel => {
        // Touchpads report pixel deltas; mice report angle deltas in 1/8° (120 per notch).
        const delta = wheel.pixelDelta.y !== 0 ? wheel.pixelDelta.y * 1.5 : wheel.angleDelta.y / 120 * pixelsPerNotch;
        const max = Math.max(0, flickable.contentHeight - flickable.height);

        flickable.contentY = Math.max(0, Math.min(max, flickable.contentY - delta));
    }
}

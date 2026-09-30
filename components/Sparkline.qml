import QtQuick
import qs.config

// Filled line graph of recent samples, newest on the right.
Canvas {
    id: root

    property var values: []
    // Fixed top of the scale (e.g. 100 for percentages); 0 scales to the largest sample.
    property real maximum: 100
    property int capacity: 60
    property color color: Theme.primary

    implicitWidth: 200
    implicitHeight: 40

    onValuesChanged: requestPaint()
    onColorChanged: requestPaint()
    onWidthChanged: requestPaint()

    onPaint: {
        const ctx = getContext("2d");

        ctx.reset();

        if (values.length < 2)
            return;

        const top = maximum > 0 ? maximum : Math.max(1, ...values);
        const step = width / (capacity - 1);
        const offset = (capacity - values.length) * step;
        const yFor = v => height - 1 - Math.min(1, v / top) * (height - 2);

        ctx.beginPath();
        ctx.moveTo(offset, height);

        values.forEach((v, i) => ctx.lineTo(offset + i * step, yFor(v)));
        ctx.lineTo(offset + (values.length - 1) * step, height);
        ctx.closePath();
        ctx.fillStyle = Qt.alpha(root.color, 0.18);
        ctx.fill();

        ctx.beginPath();
        values.forEach((v, i) => i === 0 ? ctx.moveTo(offset, yFor(v)) : ctx.lineTo(offset + i * step, yFor(v)));
        ctx.strokeStyle = root.color;
        ctx.lineWidth = 1.5;
        ctx.stroke();
    }
}

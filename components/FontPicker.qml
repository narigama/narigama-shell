import QtQuick
import QtQuick.Layouts
import qs.config

// Collapsed row showing the current font; expands to a filterable list, each entry in its own font.
ColumnLayout {
    id: root

    property string label
    property string current
    property var fonts: []
    // Text drawn in each font's preview, e.g. glyphs for icon fonts.
    property string sample: ""
    property bool expanded: false

    signal picked(string family)

    Layout.fillWidth: true
    spacing: 4

    ListRow {
        title: root.label
        subtitle: root.current
        onClicked: {
            root.expanded = !root.expanded;
            filter.text = "";
        }

        StyledText {
            text: root.expanded ? Icons.chevronDown : Icons.chevronRight
            font.family: Theme.iconFontFamily
            color: Theme.fgMuted
        }
    }

    TextField {
        id: filter

        visible: root.expanded && root.fonts.length > 8
        Layout.fillWidth: true
        placeholder: "Filter " + root.fonts.length + " fonts"
    }

    Repeater {
        model: root.expanded ? root.fonts.filter(f => f.toLowerCase().includes(filter.text.toLowerCase())) : []

        delegate: ListRow {
            required property string modelData

            Layout.leftMargin: 12
            implicitHeight: 34
            title: modelData + root.sample
            titleFont: modelData
            highlighted: modelData === root.current
            onClicked: {
                root.picked(modelData);
                root.expanded = false;
            }
        }
    }
}

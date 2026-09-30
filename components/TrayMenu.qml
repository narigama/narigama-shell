import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.config

// A tray item's DBus menu drawn inline, with submenus expanding in place. Popup menus
// would be separate surfaces, and clicking them would clear the dropdown's focus grab.
ColumnLayout {
    id: root

    property QsMenuHandle menu
    property int depth: 0

    // An entry ran its action; the owner closes the dropdown.
    signal activated

    // GTK/Qt menus mark mnemonics with "_" and escape a literal underscore as "__".
    function label(text) {
        return text.replace(/__/g, "\u0000").replace(/_/g, "").replace(/\u0000/g, "_");
    }

    Layout.fillWidth: true
    spacing: 0

    QsMenuOpener {
        id: opener

        menu: root.menu
    }

    Repeater {
        model: opener.children

        delegate: ColumnLayout {
            id: entryItem

            required property QsMenuEntry modelData
            property bool expanded: false
            readonly property bool checkable: modelData.buttonType !== QsMenuButtonType.None

            Layout.fillWidth: true
            spacing: 0

            Rectangle {
                visible: entryItem.modelData.isSeparator
                Layout.fillWidth: true
                Layout.topMargin: 4
                Layout.bottomMargin: 4
                implicitHeight: 1
                color: Theme.elevated
            }

            ListRow {
                visible: !entryItem.modelData.isSeparator
                Layout.leftMargin: root.depth * 16
                implicitHeight: 32
                icon: entryItem.checkable ? (entryItem.modelData.checkState === Qt.Checked ? Icons.check : " ") : ""
                iconColor: Theme.primary
                title: root.label(entryItem.modelData.text)
                clickable: entryItem.modelData.enabled
                opacity: entryItem.modelData.enabled ? 1 : 0.4
                onClicked: {
                    if (entryItem.modelData.hasChildren) {
                        entryItem.expanded = !entryItem.expanded;
                        return;
                    }

                    entryItem.modelData.triggered();
                    root.activated();
                }

                StyledText {
                    visible: entryItem.modelData.hasChildren
                    text: entryItem.expanded ? Icons.chevronDown : Icons.chevronRight
                    font.family: Theme.iconFontFamily
                    color: Theme.fgMuted
                }
            }

            Loader {
                Layout.fillWidth: true
                active: entryItem.expanded
                source: "TrayMenu.qml"

                onLoaded: {
                    item.menu = entryItem.modelData;
                    item.depth = root.depth + 1;
                    item.activated.connect(root.activated);
                }
            }
        }
    }
}

pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Installed fonts suitable for the bar, detected via fontconfig.
Singleton {
    id: root

    // Scalable fonts covering English, minus symbol/icon fonts.
    property var textFonts: []
    // Fonts containing the Nerd Font glyphs the bar draws (checked by two sample codepoints).
    property var iconFonts: []

    function refresh() {
        textList.running = true;
        iconList.running = true;
    }

    // fontconfig prints every alias of a family comma-separated; the first is the canonical name.
    function families(text, exclude) {
        return [...new Set(text.split("\n").map(l => l.split(",")[0].trim()).filter(f => f !== "" && !exclude.test(f)))].sort((a, b) => a.localeCompare(b));
    }

    Component.onCompleted: refresh()

    Process {
        id: textList

        command: ["fc-list", ":scalable=true:lang=en", "family"]
        stdout: StdioCollector {
            onStreamFinished: root.textFonts = root.families(text, /emoji|symbol|icon|awesome|material|dingbat|wingding|webdings|codicon|octicon|powerline|^D050000L$/i)
        }
    }

    Process {
        id: iconList

        command: ["fc-list", ":charset=f00f0 f303", "family"]
        stdout: StdioCollector {
            onStreamFinished: root.iconFonts = root.families(text, /^$/)
        }
    }
}

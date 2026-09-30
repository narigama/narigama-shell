pragma Singleton

import QtQuick
import Quickshell

// Turns a workspace into its bar label in the style picked in settings.
Singleton {
    id: root

    // [id, settings label, preview]. The Arabic preview carries left-to-right marks: without
    // them the bidi algorithm reverses space-separated Arabic digits into "٣ ٢ ١".
    readonly property var styles: [["numbers", "Numbers", "1 2 3"], ["arabic", "Arabic", "١\u200E ٢\u200E ٣"], ["roman", "Roman", "I II III"], ["japanese", "Japanese", "一 二 三"], ["custom", "Custom", "your own"]]

    readonly property var japaneseDigits: ["", "一", "二", "三", "四", "五", "六", "七", "八", "九"]

    function roman(n) {
        const numerals = [[1000, "M"], [900, "CM"], [500, "D"], [400, "CD"], [100, "C"], [90, "XC"], [50, "L"], [40, "XL"], [10, "X"], [9, "IX"], [5, "V"], [4, "IV"], [1, "I"]];
        let out = "";

        for (const [value, numeral] of numerals) {
            while (n >= value) {
                out += numeral;
                n -= value;
            }
        }

        return out;
    }

    // Traditional reading up to 99: 十 = 10, 二十一 = 21.
    function japanese(n) {
        if (n <= 0 || n >= 100)
            return String(n);

        const tens = Math.floor(n / 10);
        const ones = n % 10;

        if (tens === 0)
            return japaneseDigits[ones];

        return (tens > 1 ? japaneseDigits[tens] : "") + "十" + japaneseDigits[ones];
    }

    function label(workspace) {
        const name = workspace.name.replace(/^special:/, "");

        // Special and named workspaces keep their names.
        if (workspace.id <= 0 || String(workspace.id) !== workspace.name)
            return name;

        const id = workspace.id;

        switch (ShellState.workspaceLabels) {
        case "arabic":
            return String(id).replace(/\d/g, d => "٠١٢٣٤٥٦٧٨٩"[d]);
        case "roman":
            return roman(id);
        case "japanese":
            return japanese(id);
        case "custom":
            return ShellState.workspaceCustomLabels.split(",").map(l => l.trim())[id - 1] || String(id);
        default:
            return String(id);
        }
    }
}

pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.config

// Results for the launcher: installed apps (fuzzy, boosted by how often each is launched), open
// windows, a calculator, `>` shell commands and `:` clipboard history. Each result is
// { kind, title, subtitle, icon (theme name or path, may be ""), glyph (fallback), run() }.
Singleton {
    id: root

    readonly property int limit: 50
    // app id -> launch count, saved in launcher.json.
    property var launches: ({})

    readonly property var apps: DesktopEntries.applications.values.filter(e => !e.noDisplay)

    // Higher is better, -1 for no match. Rewards prefix and word-start matches and runs of
    // consecutive characters; every query character must appear in order.
    function fuzzy(query, text) {
        if (!text)
            return -1;

        const q = query.toLowerCase();
        const t = text.toLowerCase();
        const at = t.indexOf(q);

        if (at === 0)
            return 1000 - t.length;

        if (at > 0)
            return (/[\s\-_.]/.test(t[at - 1]) ? 800 : 600) - t.length;

        let score = 0;
        let ti = 0;
        let run = 0;

        for (const c of q) {
            const found = t.indexOf(c, ti);

            if (found < 0)
                return -1;

            run = found === ti ? run + 1 : 0;
            score += 10 + run * 5 + (found === 0 || /[\s\-_.]/.test(t[found - 1]) ? 15 : 0);
            ti = found + 1;
        }

        return score - t.length;
    }

    function appScore(query, entry) {
        const best = Math.max(fuzzy(query, entry.name), fuzzy(query, entry.genericName) - 50, ...entry.keywords.map(k => fuzzy(query, k) - 80), fuzzy(query, entry.comment) - 200);

        return best < 0 ? -1 : best + 40 * Math.log2(1 + (launches[entry.id] ?? 0));
    }

    function appResult(entry) {
        return {
            "kind": "app",
            "title": entry.name,
            "subtitle": entry.genericName || entry.comment,
            "icon": entry.icon,
            "glyph": Icons.apps,
            "run": () => root.launch(entry)
        };
    }

    // Only digits, operators, brackets and a few Math functions get near the evaluator.
    function calculate(query) {
        const expr = query.trim().replace(/^=/, "").replace(/\^/g, "**").replace(/×/g, "*").replace(/÷/g, "/");

        if (!/[\d)]\s*[-+*/%]|\*\*|^(sqrt|sin|cos|tan|log|abs|round|floor|ceil)\(/.test(expr))
            return null;

        if (!/^[\d\s+\-*/%().,]*((sqrt|sin|cos|tan|log|abs|round|floor|ceil|pi|e)[\d\s+\-*/%().,]*)*$/.test(expr))
            return null;

        try {
            const value = Function("const {sqrt,sin,cos,tan,log,abs,round,floor,ceil} = Math; const pi = Math.PI, e = Math.E; return (" + expr + ");")();

            return typeof value === "number" && isFinite(value) ? Number(value.toPrecision(12)) : null;
        } catch (e) {
            return null;
        }
    }

    function search(query) {
        const trimmed = query.trim();

        if (trimmed.startsWith(">")) {
            const command = trimmed.slice(1).trim();

            return command === "" ? [] : [
                {
                    "kind": "command",
                    "title": command,
                    "subtitle": "Run in a shell",
                    "icon": "",
                    "glyph": Icons.terminal,
                    "run": () => Quickshell.execDetached(["sh", "-c", command])
                }
            ];
        }

        if (trimmed.startsWith(":")) {
            const needle = trimmed.slice(1).trim().toLowerCase();

            return Clipboard.entries.filter(e => needle === "" || e.text.toLowerCase().includes(needle)).slice(0, limit).map(e => ({
                        "kind": "clipboard",
                        "title": e.text.replace(/\s+/g, " ").trim(),
                        "subtitle": e.image ? "Image" : "Clipboard",
                        "icon": "",
                        "glyph": e.image ? Icons.image : Icons.clipboard,
                        "run": () => Clipboard.copy(e)
                    }));
        }

        if (trimmed === "")
            return apps.slice().sort((a, b) => (launches[b.id] ?? 0) - (launches[a.id] ?? 0) || a.name.localeCompare(b.name)).slice(0, limit).map(appResult);

        const results = [];
        const value = calculate(trimmed);

        if (value !== null)
            results.push({
                "kind": "calculator",
                "title": String(value),
                "subtitle": trimmed + "  ·  Enter copies",
                "icon": "",
                "glyph": Icons.calculator,
                "score": Infinity,
                "run": () => Quickshell.execDetached(["wl-copy", String(value)])
            });

        for (const entry of apps) {
            const score = appScore(trimmed, entry);

            if (score >= 0)
                results.push(Object.assign(appResult(entry), {
                    "score": score
                }));
        }

        for (const toplevel of ToplevelManager.toplevels.values) {
            const score = Math.max(fuzzy(trimmed, toplevel.title), fuzzy(trimmed, toplevel.appId));

            if (score >= 0)
                results.push({
                    "kind": "window",
                    "title": toplevel.title || toplevel.appId,
                    "subtitle": "Window · " + toplevel.appId,
                    "icon": toplevel.appId,
                    "glyph": Icons.monitor,
                    "score": score - 100,
                    "run": () => toplevel.activate()
                });
        }

        return results.sort((a, b) => b.score - a.score).slice(0, limit);
    }

    function launch(entry) {
        const counts = Object.assign({}, launches);

        counts[entry.id] = (counts[entry.id] ?? 0) + 1;
        launches = counts;
        store.setText(JSON.stringify(counts));
        entry.execute();
    }

    FileView {
        id: store

        path: Quickshell.statePath("launcher.json")
        printErrors: false
        onLoaded: {
            try {
                root.launches = JSON.parse(text());
            } catch (e) {
                root.launches = {};
            }
        }
    }
}

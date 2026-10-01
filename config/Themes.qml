pragma Singleton

import QtQuick
import Quickshell

// Colour schemes: the ten most-starred theme families on GitHub (Sep 2026) plus official
// light variants. Slots: bg (dropdowns), surface (bar), elevated (hover/tracks), fg,
// fgMuted, fgSubtle, primary (accent), red, yellow, green, blue (the cyan/teal accent).
Singleton {
    readonly property var list: [
        {
            "id": "nightfox",
            "name": "Nightfox",
            "light": false,
            "colors": {
                "bg": "#131a24",
                "surface": "#192330",
                "elevated": "#212e3f",
                "fg": "#cdcecf",
                "fgMuted": "#71839b",
                "fgSubtle": "#4b5a6e",
                "primary": "#719cd6",
                "red": "#c94f6d",
                "yellow": "#dbc074",
                "green": "#81b29a",
                "blue": "#63cdcf"
            }
        },
        {
            "id": "dracula",
            "name": "Dracula",
            "light": false,
            "colors": {
                "bg": "#21222c",
                "surface": "#282a36",
                "elevated": "#44475a",
                "fg": "#f8f8f2",
                "fgMuted": "#6272a4",
                "fgSubtle": "#4d5578",
                "primary": "#bd93f9",
                "red": "#ff5555",
                "yellow": "#f1fa8c",
                "green": "#50fa7b",
                "blue": "#8be9fd"
            }
        },
        {
            "id": "catppuccin-mocha",
            "name": "Catppuccin Mocha",
            "light": false,
            "colors": {
                "bg": "#181825",
                "surface": "#1e1e2e",
                "elevated": "#313244",
                "fg": "#cdd6f4",
                "fgMuted": "#7f849c",
                "fgSubtle": "#585b70",
                "primary": "#89b4fa",
                "red": "#f38ba8",
                "yellow": "#f9e2af",
                "green": "#a6e3a1",
                "blue": "#94e2d5"
            }
        },
        {
            "id": "solarized-dark",
            "name": "Solarized Dark",
            "light": false,
            "colors": {
                "bg": "#002b36",
                "surface": "#073642",
                "elevated": "#0d4452",
                "fg": "#839496",
                "fgMuted": "#586e75",
                "fgSubtle": "#3a5961",
                "primary": "#268bd2",
                "red": "#dc322f",
                "yellow": "#b58900",
                "green": "#859900",
                "blue": "#2aa198"
            }
        },
        {
            "id": "gruvbox-dark",
            "name": "Gruvbox Dark",
            "light": false,
            "colors": {
                "bg": "#1d2021",
                "surface": "#282828",
                "elevated": "#3c3836",
                "fg": "#ebdbb2",
                "fgMuted": "#928374",
                "fgSubtle": "#665c54",
                "primary": "#83a598",
                "red": "#fb4934",
                "yellow": "#fabd2f",
                "green": "#b8bb26",
                "blue": "#8ec07c"
            }
        },
        {
            "id": "tokyonight",
            "name": "Tokyo Night",
            "light": false,
            "colors": {
                "bg": "#16161e",
                "surface": "#1a1b26",
                "elevated": "#292e42",
                "fg": "#c0caf5",
                "fgMuted": "#565f89",
                "fgSubtle": "#3b4261",
                "primary": "#7aa2f7",
                "red": "#f7768e",
                "yellow": "#e0af68",
                "green": "#9ece6a",
                "blue": "#7dcfff"
            }
        },
        {
            "id": "nord",
            "name": "Nord",
            "light": false,
            "colors": {
                "bg": "#2e3440",
                "surface": "#3b4252",
                "elevated": "#434c5e",
                "fg": "#d8dee9",
                "fgMuted": "#7b88a1",
                "fgSubtle": "#4c566a",
                "primary": "#81a1c1",
                "red": "#bf616a",
                "yellow": "#ebcb8b",
                "green": "#a3be8c",
                "blue": "#88c0d0"
            }
        },
        {
            "id": "kanagawa",
            "name": "Kanagawa",
            "light": false,
            "colors": {
                "bg": "#16161d",
                "surface": "#1f1f28",
                "elevated": "#2a2a37",
                "fg": "#dcd7ba",
                "fgMuted": "#727169",
                "fgSubtle": "#54546d",
                "primary": "#7e9cd8",
                "red": "#e46876",
                "yellow": "#e6c384",
                "green": "#98bb6c",
                "blue": "#7fb4ca"
            }
        },
        {
            "id": "everforest-dark",
            "name": "Everforest Dark",
            "light": false,
            "colors": {
                "bg": "#232a2e",
                "surface": "#2d353b",
                "elevated": "#3d484d",
                "fg": "#d3c6aa",
                "fgMuted": "#859289",
                "fgSubtle": "#56635f",
                "primary": "#7fbbb3",
                "red": "#e67e80",
                "yellow": "#dbbc7f",
                "green": "#a7c080",
                "blue": "#83c092"
            }
        },
        {
            "id": "onedark",
            "name": "One Dark",
            "light": false,
            "colors": {
                "bg": "#21252b",
                "surface": "#282c34",
                "elevated": "#3e4452",
                "fg": "#abb2bf",
                "fgMuted": "#5c6370",
                "fgSubtle": "#4b5263",
                "primary": "#61afef",
                "red": "#e06c75",
                "yellow": "#e5c07b",
                "green": "#98c379",
                "blue": "#56b6c2"
            }
        },
        {
            "id": "catppuccin-latte",
            "name": "Catppuccin Latte",
            "light": true,
            "colors": {
                "bg": "#e6e9ef",
                "surface": "#eff1f5",
                "elevated": "#ccd0da",
                "fg": "#4c4f69",
                "fgMuted": "#8c8fa1",
                "fgSubtle": "#acb0be",
                "primary": "#1e66f5",
                "red": "#d20f39",
                "yellow": "#df8e1d",
                "green": "#40a02b",
                "blue": "#179299"
            }
        },
        {
            "id": "solarized-light",
            "name": "Solarized Light",
            "light": true,
            "colors": {
                "bg": "#eee8d5",
                "surface": "#fdf6e3",
                "elevated": "#e4ddc8",
                "fg": "#657b83",
                "fgMuted": "#93a1a1",
                "fgSubtle": "#c3c7bc",
                "primary": "#268bd2",
                "red": "#dc322f",
                "yellow": "#b58900",
                "green": "#859900",
                "blue": "#2aa198"
            }
        },
        {
            "id": "gruvbox-light",
            "name": "Gruvbox Light",
            "light": true,
            "colors": {
                "bg": "#f2e5bc",
                "surface": "#fbf1c7",
                "elevated": "#ebdbb2",
                "fg": "#3c3836",
                "fgMuted": "#928374",
                "fgSubtle": "#bdae93",
                "primary": "#076678",
                "red": "#9d0006",
                "yellow": "#b57614",
                "green": "#79740e",
                "blue": "#427b58"
            }
        },
        {
            "id": "tokyonight-day",
            "name": "Tokyo Night Day",
            "light": true,
            "colors": {
                "bg": "#d0d5e3",
                "surface": "#e1e2e7",
                "elevated": "#c4c8da",
                "fg": "#3760bf",
                "fgMuted": "#8990b3",
                "fgSubtle": "#a8aecb",
                "primary": "#2e7de9",
                "red": "#f52a65",
                "yellow": "#8c6c3e",
                "green": "#587539",
                "blue": "#007197"
            }
        },
        {
            "id": "dayfox",
            "name": "Dayfox",
            "light": true,
            "colors": {
                "bg": "#e4dcd4",
                "surface": "#f6f2ee",
                "elevated": "#dbd1dd",
                "fg": "#3d2b5a",
                "fgMuted": "#837a72",
                "fgSubtle": "#aab0ad",
                "primary": "#2848a9",
                "red": "#a5222f",
                "yellow": "#ac5402",
                "green": "#396847",
                "blue": "#287980"
            }
        },
        {
            "id": "rose-pine-dawn",
            "name": "Rosé Pine Dawn",
            "light": true,
            "colors": {
                "bg": "#f2e9e1",
                "surface": "#faf4ed",
                "elevated": "#dfdad9",
                "fg": "#575279",
                "fgMuted": "#797593",
                "fgSubtle": "#9893a5",
                "primary": "#907aa9",
                "red": "#b4637a",
                "yellow": "#ea9d34",
                "green": "#286983",
                "blue": "#56949f"
            }
        },
        {
            "id": "everforest-light",
            "name": "Everforest Light",
            "light": true,
            "colors": {
                "bg": "#efebd4",
                "surface": "#fdf6e3",
                "elevated": "#e6e2cc",
                "fg": "#5c6a72",
                "fgMuted": "#829181",
                "fgSubtle": "#a6b0a0",
                "primary": "#35a77c",
                "red": "#f85552",
                "yellow": "#dfa000",
                "green": "#8da101",
                "blue": "#3a94c5"
            }
        },
        {
            "id": "one-light",
            "name": "One Light",
            "light": true,
            "colors": {
                "bg": "#f0f0f1",
                "surface": "#fafafa",
                "elevated": "#e5e5e6",
                "fg": "#383a42",
                "fgMuted": "#696c77",
                "fgSubtle": "#a0a1a7",
                "primary": "#4078f2",
                "red": "#e45649",
                "yellow": "#c18401",
                "green": "#50a14f",
                "blue": "#0184bc"
            }
        },
        {
            "id": "github-light",
            "name": "GitHub Light",
            "light": true,
            "colors": {
                "bg": "#f6f8fa",
                "surface": "#ffffff",
                "elevated": "#d0d7de",
                "fg": "#1f2328",
                "fgMuted": "#656d76",
                "fgSubtle": "#8c959f",
                "primary": "#8250df",
                "red": "#cf222e",
                "yellow": "#9a6700",
                "green": "#1a7f37",
                "blue": "#0969da"
            }
        },
        {
            "id": "kanagawa-lotus",
            "name": "Kanagawa Lotus",
            "light": true,
            "colors": {
                "bg": "#e5ddb0",
                "surface": "#f2ecbc",
                "elevated": "#dcd5ac",
                "fg": "#545464",
                "fgMuted": "#716e61",
                "fgSubtle": "#8a8980",
                "primary": "#624c83",
                "red": "#c84053",
                "yellow": "#cc6d00",
                "green": "#6f894e",
                "blue": "#4d699b"
            }
        }
    ]

    function find(id) {
        return list.find(t => t.id === id) ?? list[0];
    }
}

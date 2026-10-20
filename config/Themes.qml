pragma Singleton

import QtQuick
import Quickshell

// Colour schemes: the ten most-starred theme families on GitHub (Sep 2026) plus official
// light variants. Slots: bg (dropdowns), surface (bar), elevated (hover/tracks), fg,
// fgMuted, fgSubtle, primary (accent), red, yellow, green, blue (the cyan/teal accent).
// kitty: the matching name in `kitten themes`.
Singleton {
    readonly property var list: [
        {
            "id": "nightfox",
            "name": "Nightfox",
            "kitty": "Nightfox",
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
            "kitty": "Dracula",
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
            "kitty": "Catppuccin-Mocha",
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
            "kitty": "Solarized Dark",
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
            "kitty": "Gruvbox Dark",
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
            "kitty": "Tokyo Night",
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
            "kitty": "Nord",
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
            "kitty": "kanagawa",
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
            "kitty": "Everforest Dark Medium",
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
            "kitty": "One Dark",
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
            "id": "rose-pine",
            "name": "Rosé Pine",
            "kitty": "Rosé Pine",
            "light": false,
            "colors": {
                "bg": "#191724",
                "surface": "#1f1d2e",
                "elevated": "#26233a",
                "fg": "#e0def4",
                "fgMuted": "#908caa",
                "fgSubtle": "#6e6a86",
                "primary": "#c4a7e7",
                "red": "#eb6f92",
                "yellow": "#f6c177",
                "green": "#31748f",
                "blue": "#9ccfd8"
            }
        },
        {
            "id": "github-dark",
            "name": "GitHub Dark",
            "kitty": "GitHub Dark",
            "light": false,
            "colors": {
                "bg": "#0d1117",
                "surface": "#161b22",
                "elevated": "#21262d",
                "fg": "#e6edf3",
                "fgMuted": "#8b949e",
                "fgSubtle": "#484f58",
                "primary": "#bc8cff",
                "red": "#ff7b72",
                "yellow": "#d29922",
                "green": "#3fb950",
                "blue": "#58a6ff"
            }
        },
        {
            "id": "monokai",
            "name": "Monokai",
            "kitty": "Monokai",
            "light": false,
            "colors": {
                "bg": "#1e1f1c",
                "surface": "#272822",
                "elevated": "#3e3d32",
                "fg": "#f8f8f2",
                "fgMuted": "#a59f85",
                "fgSubtle": "#75715e",
                "primary": "#ae81ff",
                "red": "#f92672",
                "yellow": "#e6db74",
                "green": "#a6e22e",
                "blue": "#66d9ef"
            }
        },
        {
            "id": "ayu-mirage",
            "name": "Ayu Mirage",
            "kitty": "Ayu Mirage",
            "light": false,
            "colors": {
                "bg": "#171b24",
                "surface": "#1f2430",
                "elevated": "#2b3240",
                "fg": "#d9d7ce",
                "fgMuted": "#707a8c",
                "fgSubtle": "#505766",
                "primary": "#73d0ff",
                "red": "#f28779",
                "yellow": "#ffcc66",
                "green": "#bae67e",
                "blue": "#95e6cb"
            }
        },
        {
            "id": "flexoki-dark",
            "name": "Flexoki Dark",
            "kitty": "Flexoki (Dark)",
            "light": false,
            "colors": {
                "bg": "#100f0f",
                "surface": "#1c1b1a",
                "elevated": "#282726",
                "fg": "#cecdc3",
                "fgMuted": "#878580",
                "fgSubtle": "#575653",
                "primary": "#4385be",
                "red": "#d14d41",
                "yellow": "#d0a215",
                "green": "#879a39",
                "blue": "#3aa99f"
            }
        },
        {
            "id": "selenized-dark",
            "name": "Selenized Dark",
            "kitty": "Selenized Dark",
            "light": false,
            "colors": {
                "bg": "#103c48",
                "surface": "#184956",
                "elevated": "#2d5b69",
                "fg": "#adbcbc",
                "fgMuted": "#72898f",
                "fgSubtle": "#48707a",
                "primary": "#4695f7",
                "red": "#fa5750",
                "yellow": "#dbb32d",
                "green": "#75b938",
                "blue": "#41c7b9"
            }
        },
        {
            "id": "tomorrow-night",
            "name": "Tomorrow Night",
            "kitty": "Tomorrow Night",
            "light": false,
            "colors": {
                "bg": "#161719",
                "surface": "#1d1f21",
                "elevated": "#282a2e",
                "fg": "#c5c8c6",
                "fgMuted": "#969896",
                "fgSubtle": "#666968",
                "primary": "#81a2be",
                "red": "#cc6666",
                "yellow": "#f0c674",
                "green": "#b5bd68",
                "blue": "#8abeb7"
            }
        },
        {
            "id": "zenbones-dark",
            "name": "Zenbones Dark",
            "kitty": "zenbones_dark",
            "light": false,
            "colors": {
                "bg": "#161412",
                "surface": "#1c1917",
                "elevated": "#2c2623",
                "fg": "#b4bdc3",
                "fgMuted": "#888f94",
                "fgSubtle": "#5c534d",
                "primary": "#6099c0",
                "red": "#de6e7c",
                "yellow": "#b77e64",
                "green": "#819b69",
                "blue": "#66a5ad"
            }
        },
        {
            "id": "modus-vivendi",
            "name": "Modus Vivendi",
            "kitty": "Modus Vivendi",
            "light": false,
            "colors": {
                "bg": "#000000",
                "surface": "#1e1e1e",
                "elevated": "#303030",
                "fg": "#ffffff",
                "fgMuted": "#989898",
                "fgSubtle": "#595959",
                "primary": "#79a8ff",
                "red": "#ff5f59",
                "yellow": "#d0bc00",
                "green": "#44bc44",
                "blue": "#00d3d0"
            }
        },
        {
            "id": "alabaster-dark",
            "name": "Alabaster Dark",
            "kitty": "Alabaster Dark",
            "light": false,
            "colors": {
                "bg": "#0e1415",
                "surface": "#162022",
                "elevated": "#293334",
                "fg": "#cecece",
                "fgMuted": "#8b9496",
                "fgSubtle": "#586264",
                "primary": "#4a88e4",
                "red": "#e25d56",
                "yellow": "#e9bf57",
                "green": "#73ca50",
                "blue": "#23acdd"
            }
        },
        {
            "id": "catppuccin-latte",
            "name": "Catppuccin Latte",
            "kitty": "Catppuccin-Latte",
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
            "kitty": "Solarized Light",
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
            "kitty": "Gruvbox Light",
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
            "kitty": "Tokyo Night Day",
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
            "kitty": "Dayfox",
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
            "kitty": "Rosé Pine Dawn",
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
            "kitty": "Everforest Light Medium",
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
            "kitty": "One Half Light",
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
            "kitty": "GitHub Light",
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
            "kitty": "kanagawa_light",
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
        },
        {
            "id": "ayu-light",
            "name": "Ayu Light",
            "kitty": "Ayu Light",
            "light": true,
            "colors": {
                "bg": "#f3f4f5",
                "surface": "#fafafa",
                "elevated": "#e7e8e9",
                "fg": "#5b6673",
                "fgMuted": "#828c99",
                "fgSubtle": "#abb2b9",
                "primary": "#41a6d9",
                "red": "#f07171",
                "yellow": "#f19618",
                "green": "#86b200",
                "blue": "#4cbe99"
            }
        },
        {
            "id": "flexoki-light",
            "name": "Flexoki Light",
            "kitty": "Flexoki (Light)",
            "light": true,
            "colors": {
                "bg": "#f2f0e5",
                "surface": "#fffcf0",
                "elevated": "#e6e4d9",
                "fg": "#100f0f",
                "fgMuted": "#6f6e69",
                "fgSubtle": "#b7b5ac",
                "primary": "#205ea6",
                "red": "#af3029",
                "yellow": "#ad8301",
                "green": "#66800b",
                "blue": "#24837b"
            }
        },
        {
            "id": "selenized-light",
            "name": "Selenized Light",
            "kitty": "Selenized Light",
            "light": true,
            "colors": {
                "bg": "#ece3cc",
                "surface": "#fbf3db",
                "elevated": "#d5cdb6",
                "fg": "#53676d",
                "fgMuted": "#909995",
                "fgSubtle": "#b8beb6",
                "primary": "#0072d4",
                "red": "#d2212d",
                "yellow": "#ad8900",
                "green": "#489100",
                "blue": "#009c8f"
            }
        },
        {
            "id": "tomorrow",
            "name": "Tomorrow",
            "kitty": "Tomorrow",
            "light": true,
            "colors": {
                "bg": "#f2f2f2",
                "surface": "#ffffff",
                "elevated": "#e0e0e0",
                "fg": "#4d4d4c",
                "fgMuted": "#8e908c",
                "fgSubtle": "#b4b7b4",
                "primary": "#4271ae",
                "red": "#c82829",
                "yellow": "#eab700",
                "green": "#718c00",
                "blue": "#3e999f"
            }
        },
        {
            "id": "zenbones-light",
            "name": "Zenbones Light",
            "kitty": "zenbones_light",
            "light": true,
            "colors": {
                "bg": "#e4dfdc",
                "surface": "#f0edec",
                "elevated": "#d6cdc9",
                "fg": "#2c363c",
                "fgMuted": "#6e787e",
                "fgSubtle": "#a8a19d",
                "primary": "#286486",
                "red": "#a8334c",
                "yellow": "#944927",
                "green": "#4f6c31",
                "blue": "#3b8992"
            }
        },
        {
            "id": "modus-operandi",
            "name": "Modus Operandi",
            "kitty": "Modus Operandi",
            "light": true,
            "colors": {
                "bg": "#f2f2f2",
                "surface": "#ffffff",
                "elevated": "#dfdfdf",
                "fg": "#000000",
                "fgMuted": "#595959",
                "fgSubtle": "#9f9f9f",
                "primary": "#0031a9",
                "red": "#a60000",
                "yellow": "#6f5500",
                "green": "#006800",
                "blue": "#005e8b"
            }
        },
        {
            "id": "alabaster",
            "name": "Alabaster",
            "kitty": "Alabaster",
            "light": true,
            "colors": {
                "bg": "#eeeeee",
                "surface": "#f7f7f7",
                "elevated": "#dedede",
                "fg": "#000000",
                "fgMuted": "#777777",
                "fgSubtle": "#aaaaaa",
                "primary": "#325cc0",
                "red": "#aa3731",
                "yellow": "#cb9000",
                "green": "#448c37",
                "blue": "#0083b2"
            }
        },
        {
            "id": "adwaita-light",
            "name": "Adwaita Light",
            "kitty": "Adwaita light",
            "light": true,
            "colors": {
                "bg": "#f2f1f0",
                "surface": "#fcfcfc",
                "elevated": "#deddda",
                "fg": "#3d3846",
                "fgMuted": "#77767b",
                "fgSubtle": "#b0afac",
                "primary": "#1c71d8",
                "red": "#e01b24",
                "yellow": "#e66100",
                "green": "#2ec27e",
                "blue": "#1a9a86"
            }
        },
        {
            "id": "dawnfox",
            "name": "Dawnfox",
            "kitty": "Dawnfox",
            "light": true,
            "colors": {
                "bg": "#ebe5df",
                "surface": "#faf4ed",
                "elevated": "#d0d8d8",
                "fg": "#575279",
                "fgMuted": "#797593",
                "fgSubtle": "#9893a5",
                "primary": "#286983",
                "red": "#b4637a",
                "yellow": "#ea9d34",
                "green": "#618774",
                "blue": "#56949f"
            }
        },
        {
            "id": "bluloco-light",
            "name": "Bluloco Light",
            "kitty": "Bluloco Light",
            "light": true,
            "colors": {
                "bg": "#f0f0f0",
                "surface": "#f9f9f9",
                "elevated": "#e2e2e2",
                "fg": "#373a41",
                "fgMuted": "#676a77",
                "fgSubtle": "#a0a1a7",
                "primary": "#275fe4",
                "red": "#d52753",
                "yellow": "#df631c",
                "green": "#23974a",
                "blue": "#0099e1"
            }
        }
    ]

    function find(id) {
        return list.find(t => t.id === id) ?? list[0];
    }
}

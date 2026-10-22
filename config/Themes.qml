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
            "id": "rose-pine",
            "name": "Rosé Pine",
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
            "light": true,
            "colors": {
                "bg": "#e6e9ef",
                "surface": "#eff1f5",
                "elevated": "#ccd0da",
                "fg": "#484b64",
                "fgMuted": "#65687c",
                "fgSubtle": "#acb0be",
                "primary": "#0e5bf4",
                "red": "#d10f39",
                "yellow": "#935e13",
                "green": "#307820",
                "blue": "#12757a"
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
                "fg": "#404e54",
                "fgMuted": "#5e6b6b",
                "fgSubtle": "#c3c7bc",
                "primary": "#1e6da5",
                "red": "#ca2522",
                "yellow": "#846400",
                "green": "#617000",
                "blue": "#1e756e"
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
                "fgMuted": "#716559",
                "fgSubtle": "#bdae93",
                "primary": "#076678",
                "red": "#9d0006",
                "yellow": "#8e5d10",
                "green": "#6e6a0d",
                "blue": "#3d7251"
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
                "fg": "#233e7b",
                "fgMuted": "#535b81",
                "fgSubtle": "#a8aecb",
                "primary": "#145ab9",
                "red": "#ba093c",
                "yellow": "#735833",
                "green": "#4b6431",
                "blue": "#006486"
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
                "fgMuted": "#68615a",
                "fgSubtle": "#aab0ad",
                "primary": "#2848a9",
                "red": "#a5222f",
                "yellow": "#9c4c02",
                "green": "#396847",
                "blue": "#246c72"
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
                "fg": "#4e496c",
                "fgMuted": "#6b6784",
                "fgSubtle": "#9893a5",
                "primary": "#786094",
                "red": "#a44f67",
                "yellow": "#965d10",
                "green": "#286983",
                "blue": "#42717a"
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
                "fg": "#454f55",
                "fgMuted": "#616e60",
                "fgSubtle": "#a6b0a0",
                "primary": "#267859",
                "red": "#d50c09",
                "yellow": "#8b6300",
                "green": "#637101",
                "blue": "#2c7196"
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
                "primary": "#2263f0",
                "red": "#d02e1f",
                "yellow": "#936501",
                "green": "#3d7b3c",
                "blue": "#0175a7"
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
                "fg": "#444451",
                "fgMuted": "#646156",
                "fgSubtle": "#8a8980",
                "primary": "#624c83",
                "red": "#b03344",
                "yellow": "#954f00",
                "green": "#54683b",
                "blue": "#476190"
            }
        },
        {
            "id": "ayu-light",
            "name": "Ayu Light",
            "light": true,
            "colors": {
                "bg": "#f3f4f5",
                "surface": "#fafafa",
                "elevated": "#e7e8e9",
                "fg": "#4b545f",
                "fgMuted": "#67717e",
                "fgSubtle": "#abb2b9",
                "primary": "#2177a3",
                "red": "#de1717",
                "yellow": "#a1610a",
                "green": "#5c7a00",
                "blue": "#2d7d63"
            }
        },
        {
            "id": "flexoki-light",
            "name": "Flexoki Light",
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
                "yellow": "#8a6901",
                "green": "#5e760a",
                "blue": "#217a72"
            }
        },
        {
            "id": "selenized-light",
            "name": "Selenized Light",
            "light": true,
            "colors": {
                "bg": "#ece3cc",
                "surface": "#fbf3db",
                "elevated": "#d5cdb6",
                "fg": "#3d4c50",
                "fgMuted": "#5f6864",
                "fgSubtle": "#b8beb6",
                "primary": "#0066be",
                "red": "#c71f2b",
                "yellow": "#7d6300",
                "green": "#397300",
                "blue": "#007369"
            }
        },
        {
            "id": "tomorrow",
            "name": "Tomorrow",
            "light": true,
            "colors": {
                "bg": "#f2f2f2",
                "surface": "#ffffff",
                "elevated": "#e0e0e0",
                "fg": "#4d4d4c",
                "fgMuted": "#6e706c",
                "fgSubtle": "#b4b7b4",
                "primary": "#4270ad",
                "red": "#c82829",
                "yellow": "#896b00",
                "green": "#617800",
                "blue": "#31797e"
            }
        },
        {
            "id": "zenbones-light",
            "name": "Zenbones Light",
            "light": true,
            "colors": {
                "bg": "#e4dfdc",
                "surface": "#f0edec",
                "elevated": "#d6cdc9",
                "fg": "#2c363c",
                "fgMuted": "#5d656a",
                "fgSubtle": "#a8a19d",
                "primary": "#286486",
                "red": "#a8334c",
                "yellow": "#944927",
                "green": "#4f6c31",
                "blue": "#2f6c74"
            }
        },
        {
            "id": "modus-operandi",
            "name": "Modus Operandi",
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
            "light": true,
            "colors": {
                "bg": "#eeeeee",
                "surface": "#f7f7f7",
                "elevated": "#dedede",
                "fg": "#000000",
                "fgMuted": "#6c6c6c",
                "fgSubtle": "#aaaaaa",
                "primary": "#325cc0",
                "red": "#aa3731",
                "yellow": "#8e6500",
                "green": "#3b7a30",
                "blue": "#00759e"
            }
        },
        {
            "id": "adwaita-light",
            "name": "Adwaita Light",
            "light": true,
            "colors": {
                "bg": "#f2f1f0",
                "surface": "#fcfcfc",
                "elevated": "#deddda",
                "fg": "#3d3846",
                "fgMuted": "#6f6e72",
                "fgSubtle": "#b0afac",
                "primary": "#1b6dd0",
                "red": "#d91a23",
                "yellow": "#b94e00",
                "green": "#1e7e52",
                "blue": "#157c6c"
            }
        },
        {
            "id": "dawnfox",
            "name": "Dawnfox",
            "light": true,
            "colors": {
                "bg": "#ebe5df",
                "surface": "#faf4ed",
                "elevated": "#d0d8d8",
                "fg": "#4b4769",
                "fgMuted": "#686480",
                "fgSubtle": "#9893a5",
                "primary": "#286983",
                "red": "#a04d64",
                "yellow": "#935b0f",
                "green": "#4f6e5f",
                "blue": "#406e77"
            }
        },
        {
            "id": "bluloco-light",
            "name": "Bluloco Light",
            "light": true,
            "colors": {
                "bg": "#f0f0f0",
                "surface": "#f9f9f9",
                "elevated": "#e2e2e2",
                "fg": "#373a41",
                "fgMuted": "#676a77",
                "fgSubtle": "#a0a1a7",
                "primary": "#275fe4",
                "red": "#d02651",
                "yellow": "#b45017",
                "green": "#1d7e3e",
                "blue": "#0074ab"
            }
        }
    ]

    function find(id) {
        return list.find(t => t.id === id) ?? list[0];
    }
}

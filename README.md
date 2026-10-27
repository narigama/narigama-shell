# narigama-shell

A [Quickshell](https://quickshell.org) bar, launcher, notification daemon, OSD and lock screen for Wayland compositors (Hyprland, Sway/i3, niri, labwc, Jay).

## Install

```sh
curl -fsSL https://raw.githubusercontent.com/narigama/narigama-shell/master/install.sh | bash
qs -c narigama-shell
```

Stop any existing notification daemon (`mako`, `dunst`, `swaync`) before starting the shell.

## Features

- **Bar & dropdowns** — Workspaces, media, privacy indicator, weather (Open-Meteo), clock (with optional secondary timezone), audio/per-app mixer, Wi-Fi/WireGuard/Proton VPN, Bluetooth, CPU/RAM/GPU/network graphs, disk usage, package updates, failed systemd units, notifications, clipboard history, screenshots/screen recording, colour picker, DDC/CI and laptop brightness, idle inhibitor, gamemode, battery/power profiles, tray and power menu. Modules can be toggled and reordered in Settings.
- **Launcher** — Fuzzy app and open-window search, calculator, shell runner (`>`) and clipboard search (`:`).
- **Lock screen** — `ext-session-lock` lock screen with PAM authentication, idle lock and blurred/pixelated desktop or wallpaper backdrop.
- **Notifications & OSD** — Grouped notification history with per-app mute and DND; OSD for volume, mic, brightness, network/Bluetooth changes, keyboard layout and Caps Lock.
- **Themes & wallpapers** — 40 built-in themes (20 dark, 20 light), wallpaper carousel with `matugen` palette extraction, font pickers and configurable workspace labels.

## Requirements

- Quickshell 0.3.1+
- A `wlr-layer-shell` compositor
- A [Nerd Font](https://www.nerdfonts.com) (defaults to IosevkaTermSlab Nerd Font, falls back to the first installed Nerd Font)
- PipeWire, NetworkManager and BlueZ

Optional tools (modules with missing tools hide automatically; Settings lists what to install):

| Feature | Packages |
| --- | --- |
| Updates | `pacman` + `fakeroot` (plus `paru`/`yay` for AUR), `apt`, or `dnf` |
| Screenshots & recording | `grim`, `slurp`, `wl-clipboard`; optional `wf-recorder`, `satty` |
| Clipboard history | `cliphist`, `wl-clipboard` (`wl-paste --watch cliphist store`) |
| Colour picker | `hyprpicker`, `wl-clipboard` (Hyprland) |
| External monitor brightness | `ddcutil` (`i2c` group) |
| Laptop/keyboard brightness | `brightnessctl` |
| Battery & power profiles | `upower`, `power-profiles-daemon`, `libnotify` |
| Wallpapers | `awww` (or `swaybg`), `libvips` (or `imagemagick`), optional `matugen` |
| VPN | NetworkManager WireGuard profiles and/or `protonvpn` CLI |
| GPU / Gamemode | `nvidia-smi` (AMD uses sysfs), `gamemode` |

## Compositor notes

### Hyprland

Disable layer animations on shell surfaces (the shell animates its own panels) and allow lock recovery if the shell restarts while locked:

```lua
hl.layer_rule({ name = "no-anim-narigama", match = { namespace = "^narigama-" }, no_anim = true })
misc = { allow_session_lock_restore = true }
```

### Backend differences

| Feature | Hyprland | Sway / i3 | ext-workspace (niri, labwc, Jay) |
| --- | --- | --- | --- |
| Empty workspaces shown | Yes | Occupied only | Shown as occupied |
| Window list in workspaces dropdown | Yes | No | No |
| Focused-monitor OSD & IPC | Yes | Yes | First monitor |
| Keyboard layout OSD | Yes | Yes | No |
| Caps Lock OSD | Yes | No | No |

## IPC

Run with `qs -c narigama-shell ipc call <target> <method>`:

| Call | Description |
| --- | --- |
| `dropdown toggle <name>` | Toggle a dropdown on the focused monitor |
| `dropdown toggleOn <name> <monitor>` | Toggle a dropdown on a specific monitor |
| `dropdown close` | Close any open dropdown |
| `launcher toggle` | Toggle the launcher |
| `lock lock` / `lock isLocked` | Lock the session / check lock state |
| `backlight up` / `backlight down` | Adjust screen brightness ±5% with OSD |
| `backlight keyboardUp` / `backlight keyboardDown` | Step keyboard backlight with OSD |
| `osd capsLock` / `osd message <text>` | Show Caps Lock state (Hyprland) or custom OSD text |
| `vpn toggle` / `vpn status` | Toggle the last active VPN (or Proton VPN) / print status |
| `theme set <id>` / `theme list` | Switch theme / list theme IDs |
| `settings get <key>` / `settings set <key> <json>` | Read or write a setting in `state.json` |

Dropdown names: `calendar`, `weather`, `media`, `audio`, `network`, `bluetooth`, `notifications`, `dashboard`, `cpu`, `ram`, `workspaces`, `privacy`, `disk`, `updates`, `failedUnits`, `capture`, `clipboard`, `colors`, `brightness`, `battery`, `backlight`, `settings`, `wallpapers`.

## Example keybindings

Volume changes trigger the OSD automatically, so standard `wpctl` bindings work out of the box.

**Hyprland (Lua):**

```lua
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })
hl.bind("Caps_Lock", hl.dsp.exec_cmd("sleep 0.1 && qs -c narigama-shell ipc call osd capsLock"), { locked = true })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("qs -c narigama-shell ipc call backlight up"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("qs -c narigama-shell ipc call backlight down"), { locked = true, repeating = true })
hl.bind("XF86KbdBrightnessUp", hl.dsp.exec_cmd("qs -c narigama-shell ipc call backlight keyboardUp"), { locked = true })
hl.bind("XF86KbdBrightnessDown", hl.dsp.exec_cmd("qs -c narigama-shell ipc call backlight keyboardDown"), { locked = true })
```

**Sway:**

```
bindsym --locked XF86AudioRaiseVolume exec wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+
bindsym --locked XF86AudioLowerVolume exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
bindsym --locked XF86AudioMute exec wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
bindsym --locked XF86MonBrightnessUp exec qs -c narigama-shell ipc call backlight up
bindsym --locked XF86MonBrightnessDown exec qs -c narigama-shell ipc call backlight down
```

**niri:**

```kdl
binds {
    XF86AudioRaiseVolume allow-when-locked=true { spawn "wpctl" "set-volume" "-l" "1" "@DEFAULT_AUDIO_SINK@" "5%+"; }
    XF86AudioLowerVolume allow-when-locked=true { spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "5%-"; }
    XF86AudioMute allow-when-locked=true { spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle"; }
    XF86MonBrightnessUp allow-when-locked=true { spawn "qs" "-c" "narigama-shell" "ipc" "call" "backlight" "up"; }
    XF86MonBrightnessDown allow-when-locked=true { spawn "qs" "-c" "narigama-shell" "ipc" "call" "backlight" "down"; }
}
```

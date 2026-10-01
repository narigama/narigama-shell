# narigama-shell

A [Quickshell](https://quickshell.org) status bar and desktop shell for Wayland tiling compositors: Hyprland, Sway/i3, and compositors with the ext-workspace protocol such as niri.

## Features

- Bar with workspaces, media, privacy indicator, weather, clock, volume, CPU, RAM, notifications, network, bluetooth and a system menu. Every module can be hidden from settings.
- A dropdown for each module that slides down from the bar:
  - calendar
  - hourly and 5-day weather (Open-Meteo)
  - media controls and player switching
  - audio devices and per-app volume
  - wifi and bluetooth management
  - CPU, RAM, GPU and network stats with history graphs
  - workspaces (and their windows, on Hyprland)
  - system tray
  - power actions
  - settings
- Notification daemon with popups, history grouped by app, per-app muting and do-not-disturb.
- On-screen display for volume, mic, device switches, bluetooth, network, keyboard layout and caps lock (see [Compositor support](#compositor-support) for what each compositor provides).
- Privacy indicator for apps using the microphone, camera or screen share.
- Workspace tabs that pulse when a window asks for attention.
- 15 themes (10 dark, 5 light), font pickers, and numeric, Arabic, Roman, Japanese or custom workspace labels.

## Requirements

- A compositor with wlr-layer-shell (see [Compositor support](#compositor-support))
- Quickshell 0.3.1 or newer
- A [Nerd Font](https://www.nerdfonts.com) for icons (default: IosevkaTermSlab Nerd Font)
- PipeWire and NetworkManager (for audio, privacy and network)
- BlueZ (for bluetooth)
- `nvidia-smi` for NVIDIA GPU stats (optional; AMD GPUs are read from sysfs)
- Noto Sans Arabic / Noto Sans CJK for the Arabic and Japanese workspace labels (optional)

The shell becomes the notification daemon, so stop any other daemon (mako, dunst, swaync) before running it.

## Compositor support

The compositor is detected from the environment (`HYPRLAND_INSTANCE_SIGNATURE`, then `SWAYSOCK`/`I3SOCK`, otherwise ext-workspace). Tested on Hyprland 0.56, Sway 1.12 and niri 26.04.

| | Hyprland | Sway / i3 | ext-workspace (niri, labwc, Jay) |
| --- | --- | --- | --- |
| Workspace tabs, switching, urgent pulse | Yes | Yes | Yes |
| Empty/occupied workspace styling | Yes | Sway only lists occupied workspaces | All shown as occupied |
| Windows listed in the workspaces dropdown | Yes | No | No |
| OSD and IPC on the focused monitor | Yes | Yes | First monitor (no focus info) |
| Keyboard layout OSD | Yes | Yes | No |
| Caps lock OSD | Yes | No | No |
| Click outside closes a dropdown | Yes, click passes through | Yes, click is consumed | Yes, click is consumed |

Everything else (audio, network, bluetooth, media, tray, notifications, stats) is compositor-independent. GNOME has no layer-shell, so the shell can't run there.

## Running

```sh
qs -p /path/to/narigama-shell
```

Or link it into `~/.config/quickshell/narigama-shell` and run `qs -c narigama-shell`.

## Settings

Most options live in the settings page, opened from the system menu (Arch icon, then Settings). They are saved to `~/.local/state/quickshell/by-shell/<id>/state.json`. Notification history is kept alongside in `notifications.json`.

Fixed behaviour (commands for lock, logout, reboot and power off, refresh intervals, history size) is in `config/Config.qml`.

## IPC

Everything below works with `qs -p <dir> ipc call ...` (or `qs -c <name> ipc call ...`), so it can be bound to keys.

| Command | Effect |
| --- | --- |
| `dropdown toggle <name>` | Toggle a dropdown on the focused monitor (the first monitor where the compositor doesn't report focus) |
| `dropdown toggleOn <name> <monitor>` | Toggle a dropdown on a given monitor |
| `dropdown close` | Close any open dropdown |
| `osd capsLock` | Show the caps lock state; Hyprland only (it has no caps lock event, so bind this to Caps_Lock) |
| `osd message <text>` | Show a message in the OSD |
| `theme set <id>` / `theme list` | Switch theme / list theme ids |
| `settings get <key>` / `settings set <key> <json>` | Read or change any setting |

Dropdown names: `calendar`, `weather`, `media`, `audio`, `network`, `bluetooth`, `notifications`, `dashboard`, `settings`, `cpu`, `ram`, `workspaces`, `privacy`.

The `qs` CLI swallows arguments that start with `[`, so prefix JSON arrays with a space: `settings set mutedApps ' ["Slack"]'`.

## Example bindings

The OSD reacts to volume changes on its own, so plain `wpctl` and `playerctl` bindings are enough.

Hyprland (Lua config):

```lua
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })
hl.bind("Caps_Lock", hl.dsp.exec_cmd("sleep 0.1 && qs -p /path/to/narigama-shell ipc call osd capsLock"), { locked = true })
```

Sway:

```
bindsym --locked XF86AudioRaiseVolume exec wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+
bindsym --locked XF86AudioLowerVolume exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
bindsym --locked XF86AudioMute exec wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
```

niri:

```kdl
binds {
    XF86AudioRaiseVolume allow-when-locked=true { spawn "wpctl" "set-volume" "-l" "1" "@DEFAULT_AUDIO_SINK@" "5%+"; }
    XF86AudioLowerVolume allow-when-locked=true { spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "5%-"; }
    XF86AudioMute allow-when-locked=true { spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle"; }
}
```

## Layout

| Directory | Contents |
| --- | --- |
| `shell.qml` | Entry point: one bar, dropdown host and OSD per screen, plus notification popups |
| `modules/` | Bar modules and the shell's windows |
| `dropdowns/` | Contents of each dropdown |
| `services/` | Singletons wrapping system state (compositor, notifications, stats, weather, media, OSD, privacy) |
| `components/` | Shared widgets (buttons, rows, sliders, sparklines, notification cards) |
| `config/` | Theme, themes, icons, settings store and fixed configuration |

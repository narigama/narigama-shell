# narigama-shell

A [Quickshell](https://quickshell.org) status bar and desktop shell for Wayland tiling compositors: Hyprland, Sway/i3, and compositors with the ext-workspace protocol such as niri.

## Features

- Bar at the top or bottom of the screen with workspaces, media, privacy indicator, weather, clock, volume, CPU, RAM, disk usage, package updates, failed systemd units, notifications, clipboard history, screenshot and recording, colour picker, monitor brightness, idle inhibitor, gamemode, network, bluetooth and a system menu. Modules can be hidden, reordered and moved between the left, centre and right groups by dragging them in settings.
- A dropdown for each module that slides down from the bar:
  - calendar
  - hourly and 5-day weather (Open-Meteo)
  - media controls and player switching
  - audio devices and per-app volume
  - wifi and bluetooth management
  - CPU, RAM, GPU and network stats with history graphs
  - disk usage per mount
  - pending updates, with a button to run the upgrade in a terminal
  - failed systemd units, opening their status and log in a terminal
  - screenshots (region or screen, optionally annotated in satty) and screen recording
  - clipboard history with search
  - recently picked colours
  - DDC/CI brightness per external monitor
  - workspaces (and their windows, on Hyprland)
  - system tray
  - power actions
- Launcher: slides down from the bar and searches installed apps (fuzzy, with often-launched apps ranked higher) and open windows; calculates sums, runs shell commands after `>` and searches clipboard history after `:`. Up/Down, Tab or Ctrl+N/P move through results; Enter runs one.
- Lock screen: slides down over the desktop as it locks, showing a large clock over the wallpaper or a snapshot of the desktop, blurred, pixelated or untouched (set in settings), with the password row sliding up from the bottom edge when you start typing; unlocked with your login password (PAM `system-auth`). It locks from the system menu's Lock button or `loginctl lock-session`, before suspend, after an idle timeout (10 minutes by default, set in settings) and with `ipc call lock lock`, and shows how many notifications arrived while locked.
- Notification daemon with popups (top or bottom, left, centre or right), history grouped by app, per-app muting and do-not-disturb.
- On-screen display for volume, mic, device switches, bluetooth, network, keyboard layout and caps lock (see [Compositor support](#compositor-support) for what each compositor provides).
- Privacy indicator for apps using the microphone, camera or screen share.
- Workspace tabs that pulse when a window asks for attention.
- A full-width tray the bar slides away from its edge to reveal, with tabs for settings and wallpapers. The wallpaper carousel pans with the pointer, applies to all monitors or chosen ones (awww, or swaybg as a fallback), and can derive the shell's colours from the wallpaper with matugen.
- 20 themes (10 dark, 10 light), font pickers, and numeric, Arabic, Roman, Japanese or custom workspace labels.

## Requirements

- A compositor with wlr-layer-shell (see [Compositor support](#compositor-support))
- Quickshell 0.3.1 or newer
- A [Nerd Font](https://www.nerdfonts.com) for icons (default: IosevkaTermSlab Nerd Font; if it isn't installed, the first installed Nerd Font is used)
- PipeWire and NetworkManager (for audio, privacy and network)
- BlueZ (for bluetooth)
- `nvidia-smi` for NVIDIA GPU stats (optional; AMD GPUs are read from sysfs)
- Noto Sans Arabic / Noto Sans CJK for the Arabic and Japanese workspace labels (optional)

Some modules need extra tools. Disk usage is on by default; the rest of these start hidden and can be switched on in settings. A module whose tools are missing is hidden from the bar, and its row in settings says which packages to install:

| Module | Needs |
| --- | --- |
| Package updates | pacman (plus `fakeroot`), apt or dnf; `paru` or `yay` adds AUR updates |
| Failed units | systemd |
| Screenshot and recording | `grim`, `slurp`, `wl-clipboard`; `wf-recorder` for recording, `satty` for annotation |
| Clipboard history | `cliphist`, `wl-clipboard`, and `wl-paste --watch cliphist store` running from your compositor's autostart |
| Colour picker | `hyprpicker`, `wl-clipboard` (Hyprland only) |
| Monitor brightness | `ddcutil`, with access to `/dev/i2c-*` (usually the `i2c` group) |
| Gamemode | `gamemode` |
| Wallpapers | `awww` (or `swaybg`), and `libvips` (or ImageMagick) for thumbnails; `matugen` to match colours |

Update checks: on Arch the sync databases are copied and refreshed privately with fakeroot (like `checkupdates`), so the system databases are never touched; on Debian/Ubuntu the list comes from the last `apt update`; on Fedora `dnf check-update` refreshes its own cache. The terminal for upgrades and unit logs comes from `$TERMINAL`, then `xdg-terminal-exec`, then the first of foot, kitty, alacritty, wezterm, ghostty, gnome-terminal and konsole that is installed; set `terminalCommand` in `config/Config.qml` to override it. Screenshots and recordings go to `Screenshots` and `Recordings` in your XDG Pictures and Videos folders, and wallpapers default to `Wallpapers` in Pictures. Weather stays hidden until a city is set in settings.

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
| Click outside closes a dropdown | Yes (that click is consumed) | Yes (that click is consumed) | Yes (that click is consumed) |

Everything else (audio, network, bluetooth, media, tray, notifications, stats) is compositor-independent. GNOME has no layer-shell, so the shell can't run there.

## Hyprland layer rules

The shell animates its own panels, and maps dropdowns only while they're open. Turn off Hyprland's layer animations for its surfaces, or they fade in as well as sliding:

```lua
hl.layer_rule({ name = "no-anim-narigama", match = { namespace = "^narigama-" }, no_anim = true })
```

## Lock screen

The lock uses the ext-session-lock protocol (Hyprland, Sway, niri). If the shell restarts while locked, it locks again on start, but the compositor has to allow a new client to take over the lock; otherwise a crash leaves the compositor's fallback screen until you unlock from a TTY. On Hyprland, enable it with:

```lua
misc = { allow_session_lock_restore = true }
```

On Arch, `system-auth` includes `pam_faillock`, so three wrong passwords lock the account for 10 minutes (`faillock --user $USER --reset` as root clears it). The lock replaces hyprlock/swaylock and hypridle/swayidle for locking; logind's Unlock signal is ignored, so only the password unlocks.

## Running

```sh
qs -p /path/to/narigama-shell
```

Or link it into `~/.config/quickshell/narigama-shell` and run `qs -c narigama-shell`.

## Settings

Most options live in the settings tray, opened from the system menu (your distro's logo, then Settings) or with `ipc call dropdown toggle settings`; Escape, the close button or clicking elsewhere closes it. They are saved to `~/.local/state/quickshell/by-shell/<id>/state.json`. Notification history is kept alongside in `notifications.json`.

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
| `launcher toggle` | Open or close the launcher on the focused monitor (bind this to a key) |
| `lock lock` / `lock isLocked` | Lock the screen / report whether it's locked (there's no unlock call) |
| `theme set <id>` / `theme list` | Switch theme / list theme ids |
| `settings get <key>` / `settings set <key> <json>` | Read or change any setting |

Dropdown names: `calendar`, `weather`, `media`, `audio`, `network`, `bluetooth`, `notifications`, `dashboard`, `cpu`, `ram`, `workspaces`, `privacy`, `disk`, `updates`, `failedUnits`, `capture`, `clipboard`, `colors`, `brightness`. The tray tabs open the same way: `settings`, `wallpapers`.

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

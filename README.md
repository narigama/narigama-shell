# narigama-shell

[Quickshell](https://quickshell.org) bar, launcher, notifications, OSD and lock screen for Wayland (Hyprland, Sway/i3, niri).

## Install

Requires Quickshell 0.3.1+, a Nerd Font, PipeWire, NetworkManager and BlueZ. Optional tools are listed in Settings where needed. Stop any other notification daemon (`mako`, `dunst`, `swaync`) before running.

```sh
curl -fsSL https://raw.githubusercontent.com/narigama/narigama-shell/master/install.sh | bash
qs -c narigama-shell
```

## Hyprland

```lua
hl.layer_rule({ name = "no-anim-narigama", match = { namespace = "^narigama-" }, no_anim = true })
misc = { allow_session_lock_restore = true }
```

## IPC

```sh
qs -c narigama-shell ipc call dropdown toggle <name>
qs -c narigama-shell ipc call dropdown close
qs -c narigama-shell ipc call launcher toggle
qs -c narigama-shell ipc call lock lock
qs -c narigama-shell ipc call backlight up          # or down, keyboardUp, keyboardDown
qs -c narigama-shell ipc call osd capsLock          # or: osd message <text>
qs -c narigama-shell ipc call vpn toggle            # or status
qs -c narigama-shell ipc call theme set <id>        # or list
qs -c narigama-shell ipc call settings get <key>    # or: settings set <key> <json>
```

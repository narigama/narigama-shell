#!/usr/bin/env bash
set -euo pipefail

repo="${NARIGAMA_SHELL_REPO:-https://github.com/narigama/narigama-shell.git}"
dir="${NARIGAMA_SHELL_DIR:-${XDG_CONFIG_HOME:-$HOME/.config}/quickshell/narigama-shell}"

if ! command -v git >/dev/null 2>&1; then
    echo "error: git is required to install narigama-shell" >&2
    exit 1
fi

if [ -d "$dir/.git" ]; then
    echo "Updating existing checkout in $dir…"
    git -C "$dir" pull --ff-only
elif [ -e "$dir" ]; then
    echo "error: $dir already exists and is not a git repository" >&2
    exit 1
else
    echo "Cloning narigama-shell into $dir…"
    mkdir -p "$(dirname "$dir")"
    git clone "$repo" "$dir"
fi

if ! command -v qs >/dev/null 2>&1; then
    echo "note: Quickshell (qs) was not found in PATH — install quickshell >= 0.3.1 before starting."
fi

if [ -f "$(dirname "$dir")/shell.qml" ]; then
    echo "note: $(dirname "$dir")/shell.qml exists at the top level, which causes Quickshell to ignore named subdirectories."
    echo "      Move it into a subdirectory before running: qs -c narigama-shell"
fi

echo "Installed to $dir"
echo "Run with: qs -c narigama-shell"

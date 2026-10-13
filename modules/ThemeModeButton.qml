import QtQuick
import qs.components
import qs.config

// Switches between the last dark and last light theme (or the wallpaper palette's mode).
BarButton {
    icon: Theme.light ? Icons.weather.sunny : Icons.weather.night
    color: Theme.fgMuted
    onLeftClicked: ShellState.toggleThemeMode()
}

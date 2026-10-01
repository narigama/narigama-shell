import QtQuick
import qs.components
import qs.config
import qs.services

// Condition glyph and temperature; hidden until the first forecast arrives.
BarButton {
    readonly property var current: Weather.current

    icon: current ? Weather.icon(current.weather_code, current.is_day) : ""
    label: current ? Math.round(current.temperature_2m) + "°" : ""
    color: Theme.yellow
    leftDropdown: "weather"
}

pragma Singleton

import QtQuick
import Quickshell
import qs.config

// Open-Meteo: geocodes ShellState.weatherLocation, then polls the forecast.
Singleton {
    id: root

    property string locationName: ShellState.weatherLocation
    property real latitude: NaN
    property real longitude: NaN

    property var current: null
    property var daily: []
    // Every forecast hour; the dropdown picks the upcoming ones against the clock.
    property var hourly: []
    property string error: ""
    property date updatedAt

    // WMO weather interpretation codes, grouped onto the glyphs we have.
    readonly property var codes: ({
            "0": ["Clear", "sunny"],
            "1": ["Mainly clear", "sunny"],
            "2": ["Partly cloudy", "partlyCloudy"],
            "3": ["Overcast", "cloudy"],
            "45": ["Fog", "fog"],
            "48": ["Rime fog", "fog"],
            "51": ["Light drizzle", "rainy"],
            "53": ["Drizzle", "rainy"],
            "55": ["Dense drizzle", "rainy"],
            "56": ["Freezing drizzle", "snowyRainy"],
            "57": ["Freezing drizzle", "snowyRainy"],
            "61": ["Light rain", "rainy"],
            "63": ["Rain", "rainy"],
            "65": ["Heavy rain", "pouring"],
            "66": ["Freezing rain", "snowyRainy"],
            "67": ["Freezing rain", "snowyRainy"],
            "71": ["Light snow", "snowy"],
            "73": ["Snow", "snowy"],
            "75": ["Heavy snow", "snowy"],
            "77": ["Snow grains", "snowy"],
            "80": ["Rain showers", "rainy"],
            "81": ["Rain showers", "pouring"],
            "82": ["Violent showers", "pouring"],
            "85": ["Snow showers", "snowy"],
            "86": ["Snow showers", "snowy"],
            "95": ["Thunderstorm", "lightning"],
            "96": ["Thunderstorm, hail", "hail"],
            "99": ["Thunderstorm, hail", "hail"]
        })

    function describe(code) {
        return (codes[String(code)] ?? ["Unknown", "cloudy"])[0];
    }

    function icon(code, isDay) {
        let name = (codes[String(code)] ?? ["", "cloudy"])[1];

        if (!isDay && name === "sunny")
            name = "night";
        else if (!isDay && name === "partlyCloudy")
            name = "nightPartlyCloudy";

        return Icons.weather[name];
    }

    function getJson(url, callback) {
        const request = new XMLHttpRequest();

        request.onreadystatechange = () => {
            if (request.readyState !== XMLHttpRequest.DONE)
                return;

            if (request.status !== 200) {
                root.error = "HTTP " + request.status;
                return;
            }

            root.error = "";
            callback(JSON.parse(request.responseText));
        };
        request.open("GET", url);
        request.send();
    }

    function refresh() {
        if (isNaN(latitude)) {
            getJson("https://geocoding-api.open-meteo.com/v1/search?count=1&name=" + encodeURIComponent(ShellState.weatherLocation), data => {
                const place = data.results?.[0];

                if (!place) {
                    root.error = "Unknown location " + ShellState.weatherLocation;
                    return;
                }

                root.locationName = place.name;
                root.latitude = place.latitude;
                root.longitude = place.longitude;
                root.refresh();
            });
            return;
        }

        const url = "https://api.open-meteo.com/v1/forecast?latitude=" + latitude + "&longitude=" + longitude + "&current=temperature_2m,apparent_temperature,relative_humidity_2m,weather_code,wind_speed_10m,is_day" + "&hourly=temperature_2m,weather_code,precipitation_probability,is_day" + "&daily=weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max" + "&timezone=auto&forecast_days=5";

        getJson(url, data => {
            root.current = data.current;
            root.daily = data.daily.time.map((day, i) => ({
                        "date": new Date(day + "T12:00:00"),
                        "code": data.daily.weather_code[i],
                        "max": data.daily.temperature_2m_max[i],
                        "min": data.daily.temperature_2m_min[i],
                        "precipitation": data.daily.precipitation_probability_max[i]
                    }));
            root.hourly = data.hourly.time.map((time, i) => ({
                        "time": new Date(time),
                        "temp": data.hourly.temperature_2m[i],
                        "code": data.hourly.weather_code[i],
                        "precipitation": data.hourly.precipitation_probability[i],
                        "isDay": data.hourly.is_day[i]
                    }));
            root.updatedAt = new Date();
        });
    }

    // A new location needs geocoding again before the forecast can refresh.
    Connections {
        target: ShellState

        function onWeatherLocationChanged() {
            root.latitude = NaN;
            root.longitude = NaN;
            root.current = null;
            root.daily = [];
            root.hourly = [];
            root.refresh();
        }
    }

    Timer {
        interval: Config.weatherRefreshMs
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }
}

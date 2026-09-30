pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property real cpuPercent: 0
    property var corePercents: []
    property var loadAverage: [0, 0, 0]
    property real cpuTemp: NaN

    property real ramPercent: 0

    // Rolling samples for the sparklines, newest last.
    readonly property int historyLength: 60
    property var cpuHistory: []
    property var ramHistory: []
    property var rxHistory: []
    property var txHistory: []

    // Bytes per second across physical interfaces.
    property real rxRate: 0
    property real txRate: 0
    property var lastNet: null

    // [{ name, usage (%), temp (°C), memUsed, memTotal (MiB), power (W, NaN if unknown), history }]
    property var gpus: []
    property var nvidiaGpus: []
    property var amdGpus: []
    property var gpuHistories: ({})

    function pushHistory(history, value) {
        return history.concat([value]).slice(-historyLength);
    }

    function formatRate(bytesPerSecond) {
        if (bytesPerSecond >= 1048576)
            return (bytesPerSecond / 1048576).toFixed(1) + " MB/s";

        return (bytesPerSecond / 1024).toFixed(0) + " KB/s";
    }

    function updateGpus() {
        const all = nvidiaGpus.concat(amdGpus);
        const histories = Object.assign({}, gpuHistories);

        for (const gpu of all) {
            histories[gpu.name] = pushHistory(histories[gpu.name] ?? [], gpu.usage);
            gpu.history = histories[gpu.name];
        }

        gpuHistories = histories;
        gpus = all;
    }
    // kB, straight from /proc/meminfo.
    property var memory: ({
            "total": 0,
            "used": 0,
            "available": 0,
            "cached": 0,
            "buffers": 0,
            "swapTotal": 0,
            "swapUsed": 0
        })

    // Set while a dropdown shows the process tables, so `top`/`ps` only run when needed.
    property bool cpuProcessesWanted: false
    property bool ramProcessesWanted: false
    property var topCpuProcesses: []
    property var topRamProcesses: []

    property var lastTimes: ({})

    function cpuLineUsage(key, fields) {
        const idle = fields[3] + fields[4];
        const total = fields.reduce((a, b) => a + b, 0);
        const last = lastTimes[key];

        lastTimes[key] = {
            "idle": idle,
            "total": total
        };

        if (!last || total === last.total)
            return 0;

        return 100 * (1 - (idle - last.idle) / (total - last.total));
    }

    FileView {
        id: stat

        path: "/proc/stat"
        onLoaded: {
            const cores = [];

            for (const line of text().split("\n")) {
                if (!line.startsWith("cpu"))
                    break;

                const parts = line.trim().split(/\s+/);
                const usage = root.cpuLineUsage(parts[0], parts.slice(1).map(Number));

                if (parts[0] === "cpu") {
                    root.cpuPercent = usage;
                    root.cpuHistory = root.pushHistory(root.cpuHistory, usage);
                }
                else
                    cores.push(usage);
            }

            root.corePercents = cores;
        }
    }

    FileView {
        id: loadavg

        path: "/proc/loadavg"
        onLoaded: root.loadAverage = text().split(" ").slice(0, 3).map(Number)
    }

    FileView {
        id: cpuTempFile

        path: ""
        onLoaded: root.cpuTemp = Number(text()) / 1000
    }

    // First hwmon exposing a CPU package sensor (AMD k10temp/zenpower, Intel coretemp).
    Process {
        running: true
        command: ["sh", "-c", "for d in /sys/class/hwmon/hwmon*; do case $(cat $d/name) in k10temp|zenpower|coretemp) echo $d/temp1_input; exit;; esac; done"]
        stdout: StdioCollector {
            onStreamFinished: cpuTempFile.path = text.trim()
        }
    }

    FileView {
        id: meminfo

        path: "/proc/meminfo"
        onLoaded: {
            const values = {};

            for (const line of text().split("\n")) {
                const match = line.match(/^(\w+):\s+(\d+)/);

                if (match)
                    values[match[1]] = Number(match[2]);
            }

            const used = values.MemTotal - values.MemAvailable;

            root.memory = {
                "total": values.MemTotal,
                "used": used,
                "available": values.MemAvailable,
                "cached": values.Cached + (values.SReclaimable ?? 0),
                "buffers": values.Buffers,
                "swapTotal": values.SwapTotal,
                "swapUsed": values.SwapTotal - values.SwapFree
            };
            root.ramPercent = 100 * used / values.MemTotal;
            root.ramHistory = root.pushHistory(root.ramHistory, root.ramPercent);
        }
    }

    // Second `top` iteration, since the first reports averages since process start.
    Process {
        id: topCpu

        command: ["sh", "-c", "top -b -n 2 -d 0.5 -w 256 -o %CPU | awk '/^ *PID/{block++; next} block==2 && NF>=12 {print $1\"\\t\"$9\"\\t\"$12}' | head -n 6"]
        stdout: StdioCollector {
            onStreamFinished: root.topCpuProcesses = text.trim().split("\n").filter(l => l !== "").map(l => {
                    const [pid, cpu, name] = l.split("\t");

                    return {
                        "pid": pid,
                        "value": Number(cpu.replace(",", ".")),
                        "name": name
                    };
                })
        }
    }

    Process {
        id: topRam

        command: ["ps", "-eo", "pid=,rss=,comm=", "--sort=-rss"]
        stdout: StdioCollector {
            onStreamFinished: root.topRamProcesses = text.trim().split("\n").slice(0, 6).map(l => {
                    const [pid, rss, ...name] = l.trim().split(/\s+/);

                    return {
                        "pid": pid,
                        "value": Number(rss),
                        "name": name.join(" ")
                    };
                })
        }
    }

    // Skips loopback and virtual interfaces (containers, bridges, VPN tunnels count as virtual too).
    FileView {
        id: netdev

        path: "/proc/net/dev"
        onLoaded: {
            let rx = 0;
            let tx = 0;

            for (const line of text().split("\n").slice(2)) {
                const [name, rest] = line.split(":");

                if (!rest || /^(lo|docker|veth|br-|virbr|vnet|tun|tap|wg|tailscale)/.test(name.trim()))
                    continue;

                const fields = rest.trim().split(/\s+/).map(Number);

                rx += fields[0];
                tx += fields[8];
            }

            const now = Date.now();

            if (root.lastNet) {
                const seconds = (now - root.lastNet.time) / 1000;

                root.rxRate = Math.max(0, (rx - root.lastNet.rx) / seconds);
                root.txRate = Math.max(0, (tx - root.lastNet.tx) / seconds);
                root.rxHistory = root.pushHistory(root.rxHistory, root.rxRate);
                root.txHistory = root.pushHistory(root.txHistory, root.txRate);
            }

            root.lastNet = {
                "rx": rx,
                "tx": tx,
                "time": now
            };
        }
    }

    // One long-running nvidia-smi sampling every 2s, rather than a process per poll.
    Process {
        id: nvidiaSmi

        running: true
        command: ["sh", "-c", "command -v nvidia-smi >/dev/null && exec nvidia-smi --query-gpu=name,utilization.gpu,temperature.gpu,memory.used,memory.total,power.draw --format=csv,noheader,nounits -l 2"]
        stdout: SplitParser {
            onRead: line => {
                const [name, usage, temp, memUsed, memTotal, power] = line.split(",").map(v => v.trim());
                const gpu = {
                    "name": name,
                    "usage": Number(usage),
                    "temp": Number(temp),
                    "memUsed": Number(memUsed),
                    "memTotal": Number(memTotal),
                    "power": Number(power)
                };

                root.nvidiaGpus = root.nvidiaGpus.filter(g => g.name !== name).concat([gpu]);
                root.updateGpus();
            }
        }
    }

    // amdgpu exposes usage, VRAM and temperature in sysfs.
    Process {
        id: amdQuery

        command: ["sh", "-c", "for d in /sys/class/drm/card*/device; do [ -f $d/gpu_busy_percent ] || continue; echo \"$(cat $d/gpu_busy_percent) $(cat $d/mem_info_vram_used) $(cat $d/mem_info_vram_total) $(cat $d/hwmon/hwmon*/temp1_input 2>/dev/null | head -1) $(basename $(dirname $d))\"; done"]
        stdout: StdioCollector {
            onStreamFinished: {
                root.amdGpus = text.trim().split("\n").filter(l => l !== "").map(l => {
                    const [usage, memUsed, memTotal, temp, card] = l.split(" ");

                    return {
                        "name": "AMD Radeon (" + card + ")",
                        "usage": Number(usage),
                        "temp": Number(temp) / 1000,
                        "memUsed": Number(memUsed) / 1048576,
                        "memTotal": Number(memTotal) / 1048576,
                        "power": NaN
                    };
                });
                root.updateGpus();
            }
        }
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            stat.reload();
            loadavg.reload();
            netdev.reload();

            if (!amdQuery.running)
                amdQuery.running = true;

            if (cpuTempFile.path !== "")
                cpuTempFile.reload();

            if (root.cpuProcessesWanted && !topCpu.running)
                topCpu.running = true;

            if (root.ramProcessesWanted && !topRam.running)
                topRam.running = true;
        }
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: meminfo.reload()
    }

    onCpuProcessesWantedChanged: {
        if (cpuProcessesWanted)
            topCpu.running = true;
    }

    onRamProcessesWantedChanged: {
        if (ramProcessesWanted)
            topRam.running = true;
    }
}

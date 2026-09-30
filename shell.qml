//@ pragma UseQApplication
//@ pragma Env QSG_RENDER_LOOP=threaded

import Quickshell
import qs.modules

ShellRoot {
    Variants {
        model: Quickshell.screens

        Scope {
            id: perScreen

            required property ShellScreen modelData

            Bar {
                id: bar

                modelData: perScreen.modelData
            }

            DropdownHost {
                targetScreen: perScreen.modelData
                bar: bar
            }

            OsdWindow {
                targetScreen: perScreen.modelData
            }
        }
    }

    NotificationPopups {
        screen: Quickshell.screens[0]
    }
}

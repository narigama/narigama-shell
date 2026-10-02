//@ pragma UseQApplication
//@ pragma Env QSG_RENDER_LOOP=threaded

import Quickshell
import Quickshell.Wayland
import qs.modules
import qs.services

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
                barScope: bar
            }

            OsdWindow {
                targetScreen: perScreen.modelData
            }

            LockReveal {
                targetScreen: perScreen.modelData
            }
        }
    }

    WlSessionLock {
        locked: Lock.locked

        LockSurface {}
    }

    NotificationPopups {
        screen: Quickshell.screens[0]
    }
}

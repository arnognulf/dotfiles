#!/usr/bin/env python
import gi
gi.require_version("Gtk", "3.0")
from gi.repository import Gtk
import notify2
import sys

# Ubuntu's notify-osd doesn't officially support actions. However, it does have
# a dialog fallback which we can use for this demonstration. In real use, please
# respect the capabilities the notification server reports!
OVERRIDE_NO_ACTIONS = True

def help_cb(n, action):
    assert action == "help"
    print("You clicked Help")
    n.close()

def closed_cb(n):
    print("Notification closed")
    Gtk.main_quit()

if __name__ == '__main__':
    if not notify2.init("Multi Action Test", mainloop='glib'):
        sys.exit(1)
    
    server_capabilities = notify2.get_server_caps()

    n = notify2.Notification("▝▔▔▀▓▒▓▀▔▀▓▀", "")
    n.set_urgency(notify2.URGENCY_CRITICAL)
    n.set_category("device")
    if ('actions' in server_capabilities) or OVERRIDE_NO_ACTIONS:
        n.add_action("help", "DEAL WITH IT", help_cb)
    n.connect('closed', closed_cb)

    if not n.show():
        print("Failed to send notification")
        sys.exit(1)

    Gtk.main()

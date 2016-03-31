#!/usr/bin/env python3

import i3ipc
from os import environ

def write_fifo(msg):
    fifo = open('/tmp/i3_lemonbar_{:s}'.format(
        environ.get("USER")), 'w')
    fifo.write("{:s}\n".format(msg))
    fifo.close()

def on_mode_event(i3, e):
    write_fifo("MODE\t{:s}".format(e.change))

def update_workspaces(i3):
    out = {'mainbar': "WSP\t"}
    """
    WSP id,visible,focus,urgent
    """
    for wp in i3.get_workspaces():
        out['mainbar'] += "{:s},{:d},{:b},{:b},{:b}\t".format(
        wp.output, wp.num, wp.visible, wp.focused, wp.urgent)

    write_fifo(out['mainbar'])


def on_workspace_focus(i3, e):
    update_workspaces(i3)

def on_workspace_init(i3, e):
    update_workspaces(i3)

def on_workspace_urgent(i3, e):
    update_workspaces(i3)

i3 = i3ipc.Connection()
i3.on('mode', on_mode_event)
i3.on('workspace::focus', on_workspace_focus)
i3.on('workspace::init', on_workspace_init)
i3.on('workspace::urgent', on_workspace_urgent)
i3.main()

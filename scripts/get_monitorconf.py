#!/usr/bin/python
from __future__ import print_function
from subprocess import Popen, PIPE
import json

if __name__ == '__main__':
    p = Popen(['i3-msg', '-t', 'get_outputs'],
              stdin=PIPE, stdout=PIPE, stderr=PIPE)
    out, err = p.communicate()
    parsed = json.loads(out.decode('utf-8'))

    """
    [{u'active': False, u'current_workspace': None, u'name': u'xroot-0', u'rect': {u'y': 0, u'x': 0, u'height': 1080, u'width': 3840}, u'primary': False},
    {u'active': False, u'current_workspace': None, u'name': u'VGA1', u'rect': {u'y': 0, u'x': 0, u'height': 0, u'width': 0}, u'primary': False},
    {u'active': True, u'current_workspace': u'9', u'name': u'HDMI1', u'rect': {u'y': 0, u'x': 0, u'height': 1080, u'width': 1920}, u'primary': False},
    {u'active': True, u'current_workspace': u'1', u'name': u'HDMI2', u'rect': {u'y': 0, u'x': 1920, u'height': 1080, u'width': 1920}, u'primary': False}]
    """

    active_outputs = {}
    for output in parsed:
        if output['active']:
            active_outputs[output['name']] = {
                'height': output['rect']['height'], # Don't need it, but hey..
                'width': output['rect']['width'],
                'offset_x': output['rect']['x'],
                'offset_y': output['rect']['y']
            }

    out = ""
    for name in active_outputs:
        data = active_outputs[name]
        out += "{:s},{:d},{:d},{:d},{:d}\t".format(
            name, data['width'], data['height'], data['offset_x'],
            data['offset_y'])

    print(out)

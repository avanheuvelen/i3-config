#!/bin/bash

mainbar_fifo="/tmp/i3_lemonbar_${USER}"

SINK=$(pactl list short | grep RUNNING | sed -e 's,^\([0-9][0-9]*\)[^0-9].*,\1,' | head -n 1)

pactl set-sink-volume $SINK -5%

echo -e "VOL $(~/.config/i3/scripts/get_volume.sh)" > ${mainbar_fifo}

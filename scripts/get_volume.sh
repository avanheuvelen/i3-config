#!/bin/bash

SINK=$(pactl list short | grep RUNNING | sed -e 's,^\([0-9][0-9]*\)[^0-9].*,\1,' | head -n 1)

VOL=$(/usr/bin/perl ~/.config/i3/scripts/check_volume.pl $SINK)

echo $VOL

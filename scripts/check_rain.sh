#!/bin/bash

if [ -e ~/.config/i3/settings ]; then
    source ~/.config/i3/settings
else
    echo "No settings file found! (Did you copy settings.template?)" >&2
    echo "No settings file found! (Did you copy settings.template?)" > ~/.config/i3/lemonade.log
    exit 1
fi

refresh_weather () {
    curl -s http://gps.buienradar.nl/getrr.php\?lat\=$RAIN_LAT\&lon\=$RAIN_LON > /tmp/rain
}

rain_amount() {
    if [ -z "$1" ]; then
        echo 0
    elif [ "$1" -eq 0 ]; then
        echo 0
    elif [ "$1" -le 64 ]; then
        echo 1
    elif [ "$1" -le 128 ]; then
        echo 2
    elif [ "$1" -le 192 ]; then
        echo 3
    else
        echo 4
    fi
}

export -f refresh_weather

if [ -e /tmp/rain ]; then
    # Find /
    find /tmp/rain -cmin +5 | egrep '.*' > /dev/null && refresh_weather
else
    refresh_weather
fi

# Rain in the next half hour:
#head /tmp/rain -n7 | awk 'BEGIN { FS = "|"} ; {total+=$1}; {lines+=1}; END {average=total / lines}; END {printf("%02x%02x%02x", average, average, average)}'
echo -n $(rain_amount $(sed -n '1,9p' /tmp/rain | awk 'BEGIN { FS = "|"} ; {total+=$1}; {lines+=1}; END {average=total / lines}; END {printf("%d", average)}')),
echo -n $(rain_amount $(sed -n '10,18p' /tmp/rain | awk 'BEGIN { FS = "|"} ; {total+=$1}; {lines+=1}; END {average=total / lines}; END {printf("%d", average)}')),
echo $(rain_amount $(sed -n '19,17p' /tmp/rain | awk 'BEGIN { FS = "|"} ; {total+=$1}; {lines+=1}; END {average=total / lines}; END {printf("%d", average)}'))

#!/bin/bash

# Special thanks to:

# https://github.com/electro7/dotfiles/tree/master/.i3/lemonbar - For his fifo idea

#  Palette URL: http://paletton.com/#uid=73y1B0knakEk+ICm2syo7cBp15a
#  Icons: http://fortawesome.github.io/Font-Awesome/icons/

if [ -e ~/.config/i3/settings ]; then
    source ~/.config/i3/settings
else
    echo "No settings file found! (Did you copy settings.template?)" >&2
    echo "No settings file found! (Did you copy settings.template?)" > ~/.config/i3/lemonade.log
    exit 1
fi


# TODO: Reduce amount of stupidity down here.

FG="#FFB958"

CL_WARN="%{F#DF4DA8}"
CL_NOTICE="%{F#799B2B}"
CL_FGALT="%{F#A5722D}"
CL_ICON="%{F#555555}"

CL_BG="%{B$BG_COLOR}"
CL_FG="%{F$FG}"
#CL_BGF="%{B$FG}" # Background Flipped
CL_BGF="%{B#4F93CB}" # Background Flipped
CL_FGF="%{F$BG_COLOR}"  # Foreground flipped
#CL_FGALTF="%{F#644519}"  # Foreground flipped alt
CL_FGALTF="%{F#356893}"  # Foreground flipped alt
CL_ICONF="%{F#AB722D}"
CLC="%{F-}"
CLCB="%{B-}"
FONT1="%{T1}"
FONT3="%{T3}"
CL_UL="%{U#4F93CB}%{+u}"
CL_ULF="%{U#FFB958}%{+u}"
CLCU="%{U-}%{-u}"


debug() {
    if [ "$1" -le "$DEBUG" ]; then >&2 echo $2; fi
}

human_bytes() {
	awk '
		function human(x) {
			if (x<1000) {return x} else {x/=1024}
			s="kMGTEPYZ";
			while (x>=1000 && length(s)>1)
				{x/=1024; s=substr(s,2)}
			return int(x+0.5) substr(s,1,1)
		}
		{sub(/^[0-9]+/, human($1)); print}' 
}

format_bytes() {
    sed -E "s/([a-zA-Z]+)/ \1/" | awk '{printf "%6.1f'$CL_FGALT'%-3s\n", $1, $2}'
}

awk_2d() {
    awk '{printf "%2d\n", $1}'
}
colored_rain() {
    if [ "$1" -eq "0" ]; then
        echo "$CL_FGALTF-%{F-} "
    elif [ "$1" -eq "1" ]; then
        echo "%{F$RAIN_COLOR_LOW}\uf0e9%{F-} "
    elif [ "$1" -eq "2" ]; then
        echo "%{F$RAIN_COLOR_MED}\uf0e9%{F-} "
    elif [ "$1" -eq "3" ]; then
        echo "%{F$RAIN_COLOR_HIGH}\uf0e9%{F-} "
    elif [ "$1" -eq "4" ]; then
        echo "%{F$RAIN_COLOR_INSANE}\uf0e9%{F-} "
    fi
}

if [ -z "$DEBUG" ]; then
    DEBUG=0
fi

# Find out on which display we're running
if [ -z "$1" ]; then
    debug 0 "ERROR Parser must be called with display as argument"
    debug 0 "      WILL NOT RUN"
    exit 1
else
    debug 1 "Running on display $1"
    LEMON_DISPLAY=$1
fi

debug 1 'Parser init'

while read -r line ; do
    debug 2 "[$LEMON_DISPLAY] $line"
    case $line in
        SYS*)
            opts=(${line#???})
            date="${opts[0]} ${opts[1]}"
            time="${opts[2]}"
            cpu="$(echo ${opts[3]} | awk_2d)"
            memperc="$(echo ${opts[4]} | awk_2d)"
            fs_used_perc="${opts[5]}"
            fs_home_free="${opts[6]}"
            fs_home_used_perc="${opts[7]}"
            br0_up="$(echo ${opts[8]} | format_bytes)"
            br0_down="$(echo ${opts[9]} | format_bytes)"
        ;;
        RAIN*)
            set -- ${line#????}
            OLDIFS=$IFS
            IFS=','
            rainarray=(${1})
            if [ "${rainarray[0]}" -ne "0" ] || [ "${rainarray[1]}" -ne "0" ] || [ "${rainarray[2]}" -ne "0" ]; then
                rainline="`colored_rain ${rainarray[0]}``colored_rain ${rainarray[1]}``colored_rain ${rainarray[2]}`"
            else
                rainline=""
            fi
            IFS=$OLDIFS
        ;;
        TEMP*)
            opts=(${line#????})
            temperature="${opts[0]}"
        ;;
        MODE*)
            opts=(${line#????})
            mode="${CL_WARN}Mode not found \uf1c9$CLC"
            if [ ${opts[0]} == "resize" ]; then
                mode="$CLCB$CL_NOTICE \uf0b2$CLC"
            elif [ ${opts[0]} == "default" ]; then
                mode=""
            fi
        ;;
        WSP*)
            set -- ${line#???}
            # WSP id,visible,focus,urgent
            wspline=""
            while [ $# -gt 0 ] ; do
                OLDIFS=$IFS
                IFS=','
                wspflags=(${1})
                wsplinestart="%{A:CMD activate_wsp ${wspflags[1]}:}"
                wsplineend="%{A}"
                if [ "${wspflags[0]}" == "$LEMON_DISPLAY" ]; then
                    if [ "${wspflags[4]}" -eq 1 ]; then # Urgent
                        wspline+="$wsplinestart$CL_WARN ${wspflags[0]} %{B- F- -u}$wsplineend"
                    elif [ "${wspflags[3]}" -eq 1 ]; then # Focus
                        wspline+="$wsplinestart%{B$FG}$CL_FGF$CL_UL ${wspflags[1]} %{B- F- -u}$wsplineend"
                    elif [ "${wspflags[2]}" -eq 1 ]; then # Visible
                        wspline+="$wsplinestart%{B$FG}$CL_FGF ${wspflags[1]} %{B- F- -u}$wsplineend"
                    else
                        wspline+="$wsplinestart$CL_BG$CL_FG ${wspflags[1]} %{B- F- -u}$wsplineend"
                    fi
                fi
                IFS=$OLDIFS
                shift
            done
        ;;
        VOL*)
            opts=(${line#???})
            volume="${opts[0]}"
            if [ -z "$volume" ]; then volume=0; fi
            if [ "$volume" -lt 0 ]; then
                vol_icon='\uf026'
                volume=' M '
            elif [ "$volume" -lt 51 ]; then
                vol_icon='\uf027'
                volume="$(echo $volume | awk_2d)$CL_FGALT%$CLC"
            else
                vol_icon='\uf028'
                volume="$(echo $volume | awk_2d)$CL_FGALT%$CLC"
            fi
        ;;
        BTC*)
            opts=(${line#???})
            btc="${opts[0]}"
            eth="${opts[1]}"
        ;;
        POW*)
            opts=(${line#???})
            percentage="${opts[0]}"
            charging="${opts[1]}"
            if [ "$percentage" -lt "10" ]; then
                batteryline="$CL_WARN\uf244%{F-}"
            elif [ "$percentage" -lt "25" ]; then
                batteryline="$CL_ICON\uf243%{F-}"
            elif [ "$percentage" -lt "50" ]; then
                batteryline="$CL_ICON\uf242%{F-}"
            elif [ "$percentage" -lt "75" ]; then
                batteryline="$CL_ICON\uf241%{F-}"
            else
                batteryline="$CL_ICON\uf240%{F-}"
            fi
            if [ "$charging" == "yes" ]; then
                batteryline+=" $CL_ICON\uf1e6%{F-}"
            fi
        ;;

    esac
        echo -ne "$wspline"
        echo -ne "$mode"

        [ -z $BTC ] || echo -ne " $CL_ICON\uf15a${CL_FG}${btc} $CL_ICON\uf219${CL_FG}${eth}$CL_FGALT$CLC "
        echo -ne "%{c}"
        echo -ne "$CL_BGF$CL_FGF$FONT1$CL_ULF"
        echo -ne " $date $CL_FGALTF-$CL_FGF $time $CL_FGALTF-$CL_FGF"
        echo -ne " $CL_FGF${temperature}${CL_FGALTF}C$CLC"
        echo -ne " $rainline";
        echo -ne " $CLCB"
        echo -ne "%{r}$FONT3$CL_UL"

        [ -z "$CMD_BATTERY_PERCENTAGE" ] || echo -ne "$batteryline"
        echo -ne "$CL_ICON$vol_icon$CL_FG $volume"

        echo -ne " $CL_ICON\uf0ee${CL_FG}$br0_up"
        echo -ne " $CL_ICON\uf0ed${CL_FG}$br0_down"
        echo -ne " $CL_ICON\uf02a${CL_FG}${memperc}$CL_FGALT%$CLC"
        echo -ne " $CL_ICON\uf108${CL_FG}${cpu}$CL_FGALT%$CLC "
        echo -ne "$CLCU"
        echo
done

debug 1 'Parser End'

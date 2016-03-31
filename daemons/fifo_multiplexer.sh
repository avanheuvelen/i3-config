#!/bin/bash

FIFOS=(${@})


while read -r line ; do
    case $line in
        CMD*)
            opts=(${line#???})
            case ${opts[0]} in
                activate_wsp)
                    i3-msg workspace ${opts[1]} > /dev/null
                ;;
            esac
        ;;
    esac
    for fifo in "${FIFOS[@]}"; do
        echo $line > $fifo
    done
done

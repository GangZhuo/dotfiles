#!/bin/bash

SINK=$(pactl get-default-sink)
CMD=$1
case "$CMD" in
	volume) pactl set-sink-volume $SINK $2 ;;
	mute)   pactl set-sink-mute $SINK toggle ;;
	*) echo "Usage: $0 <volume +5%> | mute"
	;;
esac


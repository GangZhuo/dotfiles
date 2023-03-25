#!/usr/bin/env bash
# Prompt the use to select a SINGLE output to toggle off

TMPFILE="/tmp/output-toggle"
WOFI=wofi

if ! command -v $WOFI &> /dev/null
then
    echo "$WOFI could not be found"
    exit
fi

# notify-send "Toggling Output - DPMS"

# If the temp file exists, the monitor could be off
# Turn it back on
if test -f "$TMPFILE"; then
    output_selection=$(cat "${TMPFILE}")
    swaymsg "output ${output_selection} dpms on"
    rm "$TMPFILE"
    exit 0
fi

# Select the output to turn off
outputs=$(swaymsg -t get_outputs | jq -r ".[] | .name")
total_outputs=$(echo "${outputs}" | wc -l)
output_selection=$(echo "${outputs}" | $WOFI --dmenu --lines ${total_outputs} --prompt 'Output to turn off')

if [ -z "$output_selection" ]
then
    exit 0
fi

# Save the output name to a temporary file
echo "$output_selection" > "$TMPFILE"

# Turn off the display
swaymsg "output ${output_selection} dpms off"


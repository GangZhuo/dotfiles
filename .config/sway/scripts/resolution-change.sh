#!/usr/bin/env bash
# Prompt the user to select an output and list avaliable resolutions

WOFI=wofi

if ! command -v $WOFI &> /dev/null
then
    echo "$WOFI could not be found"
    exit
fi

# notify-send "Toggling Output - Resolution"

outputs=$(swaymsg -t get_outputs | jq -r ".[] | .name + \" '\" + .make + \" \" + .model + \" \" + .serial + \"'\" + (if .focused then \" (focused)\" else \"\" end)")
total_outputs=$(echo "${outputs}" | wc -l)
total_outputs=$((total_outputs + 2))
output_selection=$(echo "${outputs}" | $WOFI --dmenu --lines ${total_outputs} --prompt 'Output to change the resolution')

if [ -z "$output_selection" ]
then
    exit 0
fi

output_selection=$(echo "${output_selection}" | jq -R -r "split(\" '\") | .[0]")
echo $output_selection

modes=$(swaymsg -t get_outputs | jq -r ".[] | select(.name == \"${output_selection}\").modes | .[] | (.width|tostring) + \"x\" + (.height|tostring)" | uniq)
total_modes=$(echo "${modes}" | wc -l)
total_modes=$((total_modes + 2))
mode_selection=$(echo "${modes}"| $WOFI --dmenu --lines ${total_modes} --prompt 'New Resolution')

if [ -z "$mode_selection" ]
then
    exit 0
fi

swaymsg "output ${output_selection} resolution ${mode_selection}"


#!/usr/bin/bash
# when reloading sway while using clamshell mode,
# keep output disabling.
# See https://github.com/swaywm/sway/wiki#clamshell-mode
LAPTOP=$1
if grep -q open /proc/acpi/button/lid/LID0/state; then
    swaymsg output $LAPTOP enable
else
    swaymsg output $LAPTOP disable
fi

#!/bin/sh

# We need add below line into sudoers,
# see https://github.com/apognu/tuigreet?tab=readme-ov-file#power-management
#
# %greeter ALL=NOPASSWD: /bin/systemctl poweroff, /bin/systemctl reboot
#
exec tuigreet \
    --issue \
    --time --time-format "%Y-%m-%d %H:%M" \
    --power-shutdown 'sudo --non-interactive systemctl poweroff' \
    --power-reboot 'sudo --non-interactive systemctl reboot' \
    $@


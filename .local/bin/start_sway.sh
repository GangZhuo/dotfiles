#!/usr/bin/env bash

set -euo pipefail

# Fcitx
if command -v fcitx5 >/dev/null 2>&1; then
	export XMODIFIERS=@im=fcitx
	export QT_IM_MODULE=fcitx
	export GTK_IM_MODULE=fcitx
fi

# Sway
if command -v sway >/dev/null 2>&1; then
	# See https://wiki.archlinux.org/title/firefox#Wayland
	export MOZ_ENABLE_WAYLAND=1
fi

# EDITOR
if command -v nvim >/dev/null 2>&1; then
	export EDITOR=$(command -v nvim)
fi

exec sway $@ >/tmp/sway-$USER.log 2>&1


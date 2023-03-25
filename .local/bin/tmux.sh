#!/bin/bash
SCRIPT_PATH=$(readlink -f "$0")
SCRIPT_INSTALL_DIR=$(dirname "$SCRIPT_PATH")
VIR_ENV_LOCAL_DIR=$(dirname "$SCRIPT_INSTALL_DIR")
VIR_ENV_DIR=$(dirname "$VIR_ENV_LOCAL_DIR")
TMUX_CONF_PATH="$VIR_ENV_DIR/.tmux.conf"
exec /usr/bin/tmux -f "$TMUX_CONF_PATH" "$@"

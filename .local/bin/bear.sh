#!/bin/bash
SCRIPT_PATH=$(readlink -f "$0")
SCRIPT_INSTALL_DIR=$(dirname "$SCRIPT_PATH")
VIR_ENV_LOCAL_DIR=$(dirname "$SCRIPT_INSTALL_DIR")
BEAR_INSTALL_PATH="$VIR_ENV_LOCAL_DIR/bear"
exec "$BEAR_INSTALL_PATH/bin/bear" \
	--bear-path   "$BEAR_INSTALL_PATH/bin/bear" \
	--library     "$BEAR_INSTALL_PATH/lib64/bear/libexec.so" \
	--wrapper     "$BEAR_INSTALL_PATH/lib64/bear/wrapper" \
	--wrapper-dir "$BEAR_INSTALL_PATH/lib64/bear/wrapper.d" \
	"$@"

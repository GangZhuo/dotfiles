#!/bin/bash

SCRIPT_INSTALL_DIR=$(dirname $0)
LUA_LANGUAGE_SERVER_ROOT=$(dirname "$SCRIPT_INSTALL_DIR")/lua-language-server
exec "$LUA_LANGUAGE_SERVER_ROOT/bin/lua-language-server" \
	--locale   en-us \
	--logpath  $HOME/.cache/luals/log \
	"$@"

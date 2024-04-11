#!/bin/sh

if [ -z "$1" ] ; then
  FILE=/etc/greetd/config.toml
else
  FILE="$1"
fi

sed -i 's/^\(command = "agreety --cmd \/bin\/sh"\)/#\1\
command = "agreety --cmd \/usr\/local\/bin\/start_sway.sh"/' "$FILE"


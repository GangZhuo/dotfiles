#!/bin/sh

if [ -z "$1" ] ; then
  FILE=$HOME/workspace/sway/subprojects/libdrm/meson.build
else
  FILE="$1"
fi

sed -i "/meson.get_compiler('c')/ i \
add_project_arguments([\n\
  '-Wno-stringop-truncation',\n\
  '-Wno-error=packed',\n\
  '-Wno-error=array-bounds',\n\
  '-Wno-error=maybe-uninitialized',\n\
  ], language : 'c')\n" "$FILE"


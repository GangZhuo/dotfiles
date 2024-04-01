#!/usr/bin/bash

echo 
echo " You pressed the exit shortcut, this will end your Wayland session."
read -p " Do you really want to exit sway? (y/n)? " choice
case "$choice" in 
  y|Y ) swaymsg exit ;;
  n|N ) echo "no";;
  * ) echo "invalid";;
esac

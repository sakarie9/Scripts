#!/bin/bash

# https://wiki.hyprland.org/Configuring/Uncommon-tips--tricks/#minimize-steam-instead-of-killing

# Kill active if hyprctl fails
active_window_class=$(swaymsg -t get_tree | jq -r '.. | select(.type?) | select(.focused==true) | .app_id')

case "$active_window_class" in
"steam")
  xdotool getactivewindow windowunmap
  ;;
"Waydroid")
  sudo systemctl stop waydroid-container.service
  ;;
"popup_term") ;;
*)
  swaymsg kill
  ;;
esac

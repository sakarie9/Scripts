#!/bin/bash

# https://wiki.hyprland.org/Configuring/Uncommon-tips--tricks/#minimize-steam-instead-of-killing

# Kill active if hyprctl fails
active_window_class=$(swaymsg -t get_tree | jq '.. | select(.type?) | select(.focused==true) | .app_id')

if [ "$active_window_class" = "steam" ]; then
  xdotool getactivewindow windowunmap
elif [ "$active_window_class" = "Waydroid" ]; then
  sudo systemctl stop waydroid-container.service
else
  swaymsg kill
fi

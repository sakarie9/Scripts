#!/bin/bash

# https://wiki.hyprland.org/Configuring/Uncommon-tips--tricks/#minimize-steam-instead-of-killing

# Kill active if hyprctl fails
active_window_class=$(hyprctl activewindow -j | jq -r ".class")

if [ "$active_window_class" = "steam" ]; then
  xdotool getactivewindow windowunmap
elif [ "$active_window_class" = "Waydroid" ]; then
  sudo systemctl stop waydroid-container.service
else
  hyprctl dispatch killactive ""
fi

#!/bin/bash

# https://wiki.hyprland.org/Configuring/Uncommon-tips--tricks/#minimize-steam-instead-of-killing

# Kill active if hyprctl fails
active_window_class=$(swaymsg -t get_tree | jq -r '.. | select(.type?) | select(.focused==true) | .app_id')

TG_APPID="org.telegram.desktop"
AYU_APPID="com.ayugram.desktop"

case "$active_window_class" in
"steam")
  xdotool getactivewindow windowunmap
  ;;
"Waydroid")
  sudo systemctl stop waydroid-container.service
  ;;
"popup_term") ;;
"$TG_APPID")
  window_id=$(swaymsg -t get_tree | jq --arg appid "$TG_APPID" '.. | select(.app_id? == $appid) | .id')
  swaymsg "[con_id=$window_id]" move scratchpad
  ;;
"$AYU_APPID")
  window_id=$(swaymsg -t get_tree | jq --arg appid "$AYU_APPID" '.. | select(.app_id? == $appid) | .id')
  swaymsg "[con_id=$window_id]" move scratchpad
  ;;
*)
  swaymsg kill
  ;;
esac

#!/bin/bash

ENABLED=󰎈
DISABLED=󰎊
last_preset=$(gsettings get com.github.wwmm.easyeffects last-loaded-output-preset | tr -d "'")
DEFAULT_PRESET=Default

ee_enable() {
  easyeffects -l LoudnessEqualizer
  easyeffects -b 2
  notify-send "Easyeffects Enabled"
  # Trigger waybar update immediately
  pkill -SIGRTMIN+9 waybar
}

ee_disable() {
  easyeffects -l Default
  easyeffects -b 1
  notify-send "Easyeffects Disabled"
  # Trigger waybar update immediately
  pkill -SIGRTMIN+9 waybar
}

case "$1" in
"toggle" | "switch")
  if [ "$last_preset" == $DEFAULT_PRESET ]; then
    ee_enable
  else
    ee_disable
  fi
  ;;
"enable")
  ee_enable
  ;;
"disable")
  ee_disable
  ;;
*)
  if [ "$last_preset" != $DEFAULT_PRESET ]; then
    echo $ENABLED
  else
    echo $DISABLED
  fi
  ;;
esac

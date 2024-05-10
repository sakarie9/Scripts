#!/bin/bash

ENABLED=󰎈
DISABLED=󰎊
bypass=$(easyeffects -b 3)

if [[ $1 == "switch" ]]; then
  if [[ $bypass -eq 0 ]]; then
    easyeffects -b 1
    notify-send "AutoGain Disabled"
    # echo $DISABLED
  else
    easyeffects -b 2
    notify-send "AutoGain Enabled"
    # echo $ENABLED
  fi
else
  if [[ $bypass -eq 0 ]]; then
    echo $ENABLED
  else
    echo $DISABLED
  fi
fi

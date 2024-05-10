#!/bin/bash

STATE_PATH=$XDG_STATE_HOME/sink-last
sink_roc='roc-sink'
sink_default='alsa_output.pci-0000_30_00.1.hdmi-stereo'

sink_now=$(pactl info | grep Sink | cut -d ' ' -f 3)

if [ -f $STATE_PATH ]; then
  if [ ! -z $STATE_PATH ]; then
    sink_default=$(cat $STATE_PATH)
  fi
else
  touch $STATE_PATH
fi

if [ "$sink_now" = "$sink_roc" ]; then
  # roc-sink is active, switch to default
  pactl set-default-sink $sink_default
  notify-send "Switch to $sink_default"
else
  # switch to roc-sink, save current sink
  echo $sink_now >$STATE_PATH
  pactl set-default-sink $sink_roc
  notify-send "Switch to $sink_roc"
  easyeffects -b 1 # disable easyeffects
fi

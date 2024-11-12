#!/usr/bin/env bash

result=$(curl -s 'https://wttr.in/Zhengzhou?format=1&m')

case "$result" in
"Unknown location"*) ;;
*)
  echo "$result"
  ;;
esac

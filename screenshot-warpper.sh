#!/bin/bash

LOCK_PATH=/run/user/$UID/screenshot.lock

if [ ! -f ${LOCK_PATH} ]; then
  # echo "Starting screenshot"
  touch ${LOCK_PATH}
  grimblast "$@"
  rm ${LOCK_PATH}
else
  # echo "Already running"
  exit 1
fi

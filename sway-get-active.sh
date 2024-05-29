#!/bin/bash
swaymsg -t subscribe -m '["window"]' | jq -r '"-----\nname: " + .container.name + "\napp_id: " + .container.app_id + "\n-----"'

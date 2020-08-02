#!/bin/bash

source sway_env

echo "Killing WayVNC"
pkill wayvnc

echo "Restoring outputs"
swaymsg -t get_outputs -r | jq -r '.[].name | select(. | startswith("HEADLESS-") | not)' | while read -r output; do
  swaymsg output "$output" enable
  swaymsg output "$output" dpms on
done

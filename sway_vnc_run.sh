#!/bin/bash

source sway_env

dialog='dialog
--backtitle
WayVNC Sway remote setup'

function outputs_options() {
  swaymsg -t get_outputs -r | jq -r '.[] | .name + "\n" + .make + " " + .model + " (" + (.current_mode.width | tostring) + "x" + (.current_mode.height | tostring) + ")"'
}

function options_options() {
  echo disable
  echo "Disable other displays"
  echo 1
  #echo dpms
  #echo "Turn off selected local screen"
  #echo 1
}

function listen_options() {
  ip -j address | jq -r '.[] | select(.flags | index("LOOPBACK") | not) | .ifname as $ifname | .addr_info[] | select(.scope != "link") | .local + "\n" + $ifname'
  echo '0.0.0.0'
  echo 'All interfaces (IPv4)'
  echo '::'
  echo 'All interfaces (IPv6)'
}

IFSBAK="$IFS"
IFS=$'\n'
output="$($dialog --args --stdout \
  --menu 'Which output you want to stream?' 0 0 0 $(outputs_options) \
  --and-widget --no-tags --checklist 'Options' 0 0 0 $(options_options) \
  --and-widget --menu 'Address to listen on' 0 0 0 $(listen_options))"
IFS=$'\t'
lines=($output)
IFS="$IFSBAK"

output=${lines[0]}
options=(${lines[1]})
listen_addr=${lines[2]}

clear

for option in "${options[@]}"; do
  echo "$option"
  case $option in
    disable)
      swaymsg -t get_outputs -r | jq -r '.[].name | select(. != "'"$output"'")' | while read -r out; do
        swaymsg output "$out" disable
      done
      ;;
    dpms)
      swaymsg output "$output" dpms off
      ;;
  esac
done

swaymsg output "$output" dpms on  # WayVNC crashes if the screen is off
wayvnc -o "$output" "$listen_addr" & disown
echo "WayVNC started, serving $output on $listen_addr"

#!/bin/bash

source sway_env

dialog='dialog
--backtitle
WayVNC Sway remote setup'

function outputs_options() {
  swaymsg -t get_outputs -r | jq -r '.[] | .name + "\n" + .make + " " + .model + " (" + (.current_mode.width | tostring) + "x" + (.current_mode.height | tostring) + ")"'
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
output="$($dialog --stdout \
  --menu 'Which output you want to stream?' 0 0 0 $(outputs_options) \
  --and-widget  --no-label 'Yes' --yes-label 'No' --yesno 'Do you want to turn off the other outputs?' 0 0)"
turn_others_off=$?

listen_addr="$($dialog --stdout \
  --menu 'Address to listen on' 0 0 0 $(listen_options))"
IFS="$IFSBAK"

if [[ $turn_others_off == 1 ]]; then
  swaymsg -t get_outputs -r | jq -r '.[].name' | while read -r out; do
    swaymsg output "$out" disable
  done
fi

wayvnc -o "$output" "$listen_addr" & disown

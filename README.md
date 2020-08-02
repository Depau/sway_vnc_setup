# Sway VNC setup scripts

Simple script to aid bringing up a VNC server for Sway, remotely.

## Dependencies

- dialog (cdialog, terminal UI)
- wayvnc (VNC server)
- jq (for parsing swaymsg output)
- iproute2 (for listen address choices)
- sway (of course)

Since it uses `swaymsg` to probe for displays, it is only compatible with Sway.

If you want to make it compatible with all wlroots-based compositors by probing
the output manager Wayland protocol you can send me a pull request.

## sway_env

The repo includes a `sway_env` and `sway_env.fish` script that automates "stealing"
the environment variables from programs running under Sway to be able to run `swaymsg`
from SSH

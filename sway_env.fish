function steal_env
  # Steal environment from processes running in Sway
  for proc in "Xwayland" "swayidle" "swaybg" "swaybar" "waybar"
    for pid in (pgrep "$proc")
      cat "/proc/$pid/environ" | tr '\0' '\n' | grep -aEq '^SWAYSOCK=' || continue
      #source <(grep -zaE '^SWAYSOCK=|I3SOCK=|WAYLAND_DISPLAY=|DISPLAY=' "/proc/$pid/environ" | sed -r -e 's/([^\x00]*)\x00/set -x \'\1\'\n/g' | sed "s/=/' '/g")
      grep -zaE '^SWAYSOCK=|I3SOCK=|WAYLAND_DISPLAY=|DISPLAY=' "/proc/$pid/environ" | sed -r -e 's/([^\x00]*)\x00/set -gx \'\1\'\n/g' | sed "s/=/' '/g" | source
      return
    end
  end
end

if [ "$SWAYSOCK" = '' ]
  steal_env
end

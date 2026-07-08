#!/bin/sh
PATH="@sketchybar@/bin:/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources:/usr/sbin:/usr/bin:/bin"
export PATH

network="$(ipconfig getsummary en0 2>/dev/null | awk -F ' SSID : ' '/ SSID : / { print $2; exit }')"

if [ -n "$network" ]; then
  sketchybar --set wifi icon="󰖩" label.drawing=off
else
  sketchybar --set wifi icon="󰖪" label.drawing=off
fi

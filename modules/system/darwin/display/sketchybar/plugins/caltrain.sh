#!/bin/sh
PATH="@sketchybar@/bin:/usr/bin:/bin"
export PATH

output="$(CALTRAIN_OUTPUT=sketchybar @caltrainPlugin@ 2>/dev/null)"
icon="${output%%|*}"
label="${output#*|}"

if [ -z "$output" ] || [ "$icon" = "$output" ]; then
  icon="󰔫"
  label="Error"
fi

sketchybar --set caltrain icon.drawing=off label="$label"

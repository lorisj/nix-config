#!/bin/sh
PATH="@sketchybar@/bin:/usr/bin:/bin"
export PATH

volume="$INFO"
muted="$(osascript -e 'output muted of (get volume settings)' 2>/dev/null)"

if [ -z "$volume" ]; then
  volume="$(osascript -e 'output volume of (get volume settings)' 2>/dev/null)"
fi

case "$volume" in
  ""|*[!0-9]*) volume=0 ;;
esac

icon="󰕾"
if [ "$muted" = "true" ] || [ "$volume" -eq 0 ]; then
  icon="󰖁"
elif [ "$volume" -lt 35 ]; then
  icon="󰕿"
elif [ "$volume" -lt 70 ]; then
  icon="󰖀"
fi

sketchybar --set volume icon="$icon" label="$volume%"

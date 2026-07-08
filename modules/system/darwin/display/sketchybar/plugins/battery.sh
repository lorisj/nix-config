#!/bin/sh
PATH="@sketchybar@/bin:/usr/bin:/bin"
export PATH

percent="$(pmset -g batt | grep -Eo '[0-9]+%' | head -n1)"
charging="$(pmset -g batt | awk -F';' '/%/ { print $2; exit }')"
icon="󰁹"

case "$charging" in
  *charging*) icon="󰂄" ;;
esac

sketchybar --set battery icon="$icon" label="$percent"

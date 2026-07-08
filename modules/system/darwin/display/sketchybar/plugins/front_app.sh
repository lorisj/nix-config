#!/bin/sh
PATH="@sketchybar@/bin:/usr/bin:/bin"
export PATH

if [ -n "$INFO" ]; then
  app="$INFO"
else
  app="$(osascript -e 'tell application "System Events" to name of first application process whose frontmost is true' 2>/dev/null)"
fi

sketchybar --set front_app label="$app"

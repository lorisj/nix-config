#!/bin/sh
PATH="@sketchybar@/bin:/usr/bin:/bin"
export PATH

sketchybar --set date label="$(date '+%a %b %-d')" \
           --set clock label="$(date '+%-I:%M %p')"

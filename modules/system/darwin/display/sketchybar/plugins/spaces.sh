#!/bin/sh
PATH="@sketchybar@/bin:@aerospace@/bin:/usr/bin:/bin"
export PATH

if [ "${1:-}" = wake ]; then
  # Reloading recreates the system_woke subscription. SketchyBar can deliver
  # the same wake notification to the new listener, so suppress repeats.
  stamp_file="${TMPDIR:-/tmp}/sketchybar-wake-reload.stamp"
  now="$(date +%s)"
  last=0

  if [ -r "$stamp_file" ]; then
    last="$(cat "$stamp_file")"
  fi
  case "$last" in
    "" | *[!0-9]*) last=0 ;;
  esac

  if [ $((now - last)) -ge 10 ]; then
    printf '%s\n' "$now" > "$stamp_file"
    sketchybar --reload
  fi
  exit 0
fi

render_focus() {
  sid="$(aerospace list-workspaces --focused 2>/dev/null)"
  [ -n "$sid" ] || return 0

  # This is one SketchyBar transaction. Every focus event reads AeroSpace's
  # current state, so an older concurrently-started script cannot paint an
  # older workspace after a newer event.
  sketchybar \
    --set '/space\.[0-9]$/' icon.color=@text@ label.color=@text@ \
    --set '/space\.[0-9]\.app\.[0-9]$/' background.drawing=off icon.color=@text@ \
    --set '/space\.[0-9]\.highlight$/' drawing=off \
    --set "space.$sid" drawing=on icon.color=@selectedText@ label.color=@selectedText@ \
    --set "/space\.$sid\.app\.[0-9]$/" icon.color=@selectedText@ \
    --set "space.$sid.highlight" drawing=on \
    --set "space.$sid.pad.right" drawing=on \
    --set "space.$sid.gap" drawing=on
}

lock_dir="${TMPDIR:-/tmp}/sketchybar-aerospace-spaces.lock"
# Snapshot each workspace once so the complete repaint uses one coherent view.
work_dir="${TMPDIR:-/tmp}/sketchybar-aerospace-spaces.$$"

mkdir -p "$work_dir"
locked=0

cleanup() {
  if [ "$locked" -eq 1 ]; then
    rm -rf "$lock_dir"
  fi
  rm -rf "$work_dir"
}

trap cleanup EXIT

acquire_render_lock() {
  # Wake and window discovery can emit a burst of identical events. Keep the
  # first renderer and let the periodic update handle anything it coalesces.
  # Acquire this before querying AeroSpace: those queries are the expensive
  # part, and allowing every contender to take its own snapshot creates an
  # unbounded process pile-up when a render takes longer than update_freq.
  mkdir "$lock_dir" 2>/dev/null || return 1
  locked=1
}

acquire_render_lock || exit 0

focused="$(aerospace list-workspaces --focused 2>/dev/null)"

image_for_app() {
  case "$1" in
    "Google Chrome") printf "@iconDir@/google-chrome.png" ;;
    "Slack") printf "@iconDir@/slack.png" ;;
    "kitty") printf "@iconDir@/kitty.png" ;;
    *) return 1 ;;
  esac
}

hide_all_spaces() {
  for sid in 0 1 2 3 4 5 6 7 8 9; do
    sketchybar --set "space.$sid" drawing=off \
      --set "space.$sid.highlight" drawing=off \
      --set "space.$sid.pad.right" drawing=off \
      --set "space.$sid.gap" drawing=off

    for slot in 1 2 3 4 5; do
      sketchybar --set "space.$sid.app.$slot" drawing=off
    done
  done
}

if [ -z "$focused" ]; then
  hide_all_spaces
  exit 0
fi

for sid in 0 1 2 3 4 5 6 7 8 9; do
  apps_file="$work_dir/$sid"

  aerospace list-windows --workspace "$sid" --format '%{window-id}|%{app-name}' 2>/dev/null \
    | awk -F '|' '{
        window_id=$1
        app=$2
        gsub(/^[ \t]+|[ \t]+$/, "", window_id)
        gsub(/^[ \t]+|[ \t]+$/, "", app)
        if (window_id != "" && app != "" && !seen[window_id]++) print app
      }' \
    > "$apps_file"

done

latest_focused="$(aerospace list-workspaces --focused 2>/dev/null)"
if [ -n "$latest_focused" ] && [ "$latest_focused" != "$focused" ]; then
  exit 0
fi

latest_focused="$(aerospace list-workspaces --focused 2>/dev/null)"
if [ -n "$latest_focused" ] && [ "$latest_focused" != "$focused" ]; then
  exit 0
fi

for sid in 0 1 2 3 4 5 6 7 8 9; do
  window_count=0
  slot=1

  while IFS= read -r app; do
    [ -z "$app" ] && continue
    window_count=$((window_count + 1))
    [ "$window_count" -gt 5 ] && continue

    item="space.$sid.app.$slot"
    if image="$(image_for_app "$app")"; then
      sketchybar --set "$item" \
        drawing=on \
        icon="" \
        icon.drawing=on \
        icon.background.drawing=on \
        icon.background.image="$image" \
        icon.background.image.scale=0.55 \
        label.drawing=off
    else
      sketchybar --set "$item" \
        drawing=on \
        icon="󰘔" \
        icon.drawing=on \
        icon.background.drawing=off \
        label.drawing=off
    fi
    slot=$((slot + 1))
  done < "$work_dir/$sid"

  while [ "$slot" -le 5 ]; do
    sketchybar --set "space.$sid.app.$slot" drawing=off
    slot=$((slot + 1))
  done

  if [ "$window_count" -eq 0 ] && [ "$sid" != "$focused" ]; then
    sketchybar --set "space.$sid" drawing=off
    sketchybar --set "space.$sid.highlight" drawing=off \
               --set "space.$sid.pad.right" drawing=off \
               --set "space.$sid.gap" drawing=off
    continue
  fi

  if [ "$sid" = "$focused" ]; then
    sketchybar --set "space.$sid" \
      drawing=on \
      icon="$sid" \
      label.drawing=off \
      icon.padding_left=7 \
      icon.padding_right=4 \
      background.drawing=off \
      icon.color=@selectedText@ \
      label.color=@selectedText@ \
      --set "space.$sid.highlight" drawing=on \
      --set "space.$sid.pad.right" drawing=on \
      --set "space.$sid.gap" drawing=on
  else
    sketchybar --set "space.$sid" \
      drawing=on \
      icon="$sid" \
      label.drawing=off \
      icon.padding_left=7 \
      icon.padding_right=4 \
      background.drawing=off \
      icon.color=@text@ \
      label.color=@text@ \
      --set "space.$sid.highlight" drawing=off \
      --set "space.$sid.pad.right" drawing=on \
      --set "space.$sid.gap" drawing=on
  fi

  for active_slot in 1 2 3 4 5; do
    active_item="space.$sid.app.$active_slot"
    if [ "$sid" = "$focused" ] && [ "$active_slot" -le "$window_count" ] && [ "$active_slot" -le 5 ]; then
      sketchybar --set "$active_item" \
        background.drawing=off \
        icon.color=@selectedText@
    else
      sketchybar --set "$active_item" \
        background.drawing=off \
        icon.color=@text@
    fi
  done
done

# A workspace change may have raced the slower app snapshot. Re-read the
# authoritative focus once more and make it the final atomic update.
render_focus

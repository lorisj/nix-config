#!/bin/sh
PATH="@sketchybar@/bin:@aerospace@/bin:/usr/bin:/bin"
export PATH

focused="$FOCUSED_WORKSPACE"
if [ -z "$focused" ]; then
  focused="$(aerospace list-workspaces --focused 2>/dev/null)"
fi

state_file="${TMPDIR:-/tmp}/sketchybar-aerospace-spaces.state"
focus_file="${TMPDIR:-/tmp}/sketchybar-aerospace-spaces.focus"
# Snapshot each workspace once so state diffing and rendering reuse the same AeroSpace query results.
work_dir="${TMPDIR:-/tmp}/sketchybar-aerospace-spaces.$$"

mkdir -p "$work_dir"
trap 'rm -rf "$work_dir"' EXIT

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

space_has_cached_apps() {
  [ -r "$state_file" ] || return 1
  case "$(cat "$state_file")" in
    *"|$1:,"*) return 0 ;;
    *) return 1 ;;
  esac
}

cached_focused_space() {
  [ -r "$state_file" ] || return 1
  cached_state="$(cat "$state_file")"
  cached_state="${cached_state%%|*}"
  cached_state="${cached_state#focused=}"
  [ -n "$cached_state" ] || return 1
  printf '%s\n' "$cached_state"
}

update_cached_focus() {
  sid="$1"
  if [ -r "$state_file" ]; then
    cached_state="$(cat "$state_file")"
    case "$cached_state" in
      focused=*\|*) printf 'focused=%s|%s\n' "$sid" "${cached_state#*|}" > "$state_file" ;;
    esac
  fi
}

record_requested_focus() {
  sid="$1"
  printf '%s\n' "$sid" > "$focus_file"
  update_cached_focus "$sid"
}

latest_requested_focus() {
  [ -r "$focus_file" ] || return 1
  cat "$focus_file"
}

if [ -z "$focused" ]; then
  focused="$(cached_focused_space)"
fi

if [ -z "$focused" ]; then
  hide_all_spaces
  exit 0
fi

state="focused=$focused"

set_unfocused_space_fast() {
  sid="$1"

  if space_has_cached_apps "$sid"; then
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
  else
    sketchybar --set "space.$sid" drawing=off \
      --set "space.$sid.highlight" drawing=off \
      --set "space.$sid.pad.right" drawing=off \
      --set "space.$sid.gap" drawing=off
  fi

  for active_slot in 1 2 3 4 5; do
    sketchybar --set "space.$sid.app.$active_slot" \
      background.drawing=off \
      icon.color=@text@
  done
}

set_focused_space_fast() {
  sid="$1"

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

  for active_slot in 1 2 3 4 5; do
    sketchybar --set "space.$sid.app.$active_slot" \
      background.drawing=off \
      icon.color=@selectedText@
  done
}

if [ -n "$FOCUSED_WORKSPACE" ]; then
  record_requested_focus "$FOCUSED_WORKSPACE"
  if [ "$(latest_requested_focus)" != "$FOCUSED_WORKSPACE" ]; then
    exit 0
  fi
  sketchybar --set space.0.highlight drawing=off \
             --set space.1.highlight drawing=off \
             --set space.2.highlight drawing=off \
             --set space.3.highlight drawing=off \
             --set space.4.highlight drawing=off \
             --set space.5.highlight drawing=off \
             --set space.6.highlight drawing=off \
             --set space.7.highlight drawing=off \
             --set space.8.highlight drawing=off \
             --set space.9.highlight drawing=off
  if [ -n "$PREV_WORKSPACE" ] && [ "$PREV_WORKSPACE" != "$FOCUSED_WORKSPACE" ]; then
    set_unfocused_space_fast "$PREV_WORKSPACE"
  fi
  set_focused_space_fast "$FOCUSED_WORKSPACE"
  exit 0
fi

for sid in 0 1 2 3 4 5 6 7 8 9; do
  apps=""
  apps_file="$work_dir/$sid"

  aerospace list-windows --workspace "$sid" 2>/dev/null \
    | awk -F '|' '{ app=$2; gsub(/^[ \t]+|[ \t]+$/, "", app); if (app != "" && !seen[app]++) print app }' \
    > "$apps_file"

  while IFS= read -r app; do
    [ -z "$app" ] && continue
    apps="$apps,$app"
  done < "$apps_file"

  state="$state|$sid:$apps"
done

latest_focused="$(aerospace list-workspaces --focused 2>/dev/null)"
if [ -n "$latest_focused" ] && [ "$latest_focused" != "$focused" ]; then
  exit 0
fi

requested_focused="$(latest_requested_focus)"
if [ -n "$requested_focused" ] && [ "$requested_focused" != "$focused" ]; then
  exit 0
fi

cached_focused="$(cached_focused_space)"
if [ -n "$cached_focused" ] && [ "$cached_focused" != "$focused" ]; then
  exit 0
fi

if [ -r "$state_file" ] && [ "$(cat "$state_file")" = "$state" ]; then
  exit 0
fi
printf '%s\n' "$state" > "$state_file"

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

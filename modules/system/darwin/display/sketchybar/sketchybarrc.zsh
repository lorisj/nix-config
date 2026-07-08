#!@zsh@/bin/zsh

PATH="@sketchybar@/bin:@aerospace@/bin:/usr/bin:/bin"
export PATH

PLUGIN_DIR="@pluginDir@"

SURFACE=@surface@
TEXT=@text@
BORDER=@border@
ACCENT=@accent@
FRONT_APP=@frontApp@
CALTRAIN=@caltrain@
WIFI=@wifi@
VOLUME=@volume@
BATTERY=@battery@
TIME=@time@
FRONT_APP_BORDER=@frontAppBorder@
CALTRAIN_BORDER=@caltrainBorder@
WIFI_BORDER=@wifiBorder@
VOLUME_BORDER=@volumeBorder@
BATTERY_BORDER=@batteryBorder@
TIME_BORDER=@timeBorder@
ACCENT_TEXT=@accentText@
SELECTED=@selected@
BATTERY_ACCENT=@batteryAccent@
WIFI_ACCENT=@wifiAccent@
TEXT_FONT="@textFont@:Bold:14.0"

pill_bg=(
  background.drawing=on
  background.color=$SURFACE
  background.border_color=$BORDER
  background.border_width=2
  background.corner_radius=9
  background.height=34
)

pill_item=(
  icon.font="$TEXT_FONT"
  icon.color=$TEXT
  label.font="$TEXT_FONT"
  label.color=$TEXT
  icon.padding_left=8
  icon.padding_right=5
  label.padding_left=0
  label.padding_right=8
  padding_left=0
  padding_right=0
)

sketchybar --bar \
  position=bottom \
  height=34 \
  color=0x00000000 \
  shadow=off \
  padding_left=6 \
  padding_right=6 \
  margin=0 \
  y_offset=0 \
  sticky=on \
  topmost=window

sketchybar --default \
  updates=when_shown \
  drawing=on \
  icon.font="$TEXT_FONT" \
  label.font="$TEXT_FONT" \
  icon.color=$TEXT \
  label.color=$TEXT \
  icon.padding_left=7 \
  icon.padding_right=5 \
  label.padding_left=0 \
  label.padding_right=7

sketchybar --add item front_app left \
  --set front_app icon.drawing=off label="Finder" "${pill_item[@]}" \
    label.color=$ACCENT_TEXT \
    label.padding_left=12 \
    label.padding_right=12 \
    script="$PLUGIN_DIR/front_app.sh" \
  --subscribe front_app front_app_switched \
  --add bracket front_app.pill front_app \
  --set front_app.pill "${pill_bg[@]}" background.color=$FRONT_APP background.border_color=$FRONT_APP_BORDER

sketchybar --add item lhs.gap.front_caltrain left \
  --set lhs.gap.front_caltrain icon.drawing=off label.drawing=off width=4 \
    padding_left=0 padding_right=0

sketchybar --add item caltrain left \
  --set caltrain icon="󰔫" label="--" "${pill_item[@]}" \
    icon.drawing=off \
    icon.font="Symbols Nerd Font:Regular:14.0" \
    icon.color=$ACCENT_TEXT \
    label.color=$ACCENT_TEXT \
    label.padding_left=12 \
    label.padding_right=12 \
    label.y_offset=1 \
    script="$PLUGIN_DIR/caltrain.sh" update_freq=10 \
  --add bracket caltrain.pill caltrain \
  --set caltrain.pill "${pill_bg[@]}" background.color=$CALTRAIN background.border_color=$CALTRAIN_BORDER

space_items=()
for sid in 0 1 2 3 4 5 6 7 8 9; do
  sketchybar --add item "space.$sid" center \
    --set "space.$sid" icon="$sid" label="" "${pill_item[@]}" \
      width=20 \
      icon.font="$TEXT_FONT" \
      icon.padding_left=7 \
      icon.padding_right=4 \
      label.drawing=off \
      padding_left=0 \
      padding_right=0 \
      label.align=center \
      click_script="aerospace workspace $sid"
  space_items+=("space.$sid")

  for slot in 1 2 3 4 5; do
    sketchybar --add item "space.$sid.app.$slot" center \
      --set "space.$sid.app.$slot" icon="" label.drawing=off \
        width=17 \
        icon.font="Symbols Nerd Font:Regular:13.0" \
        icon.color=$TEXT \
        icon.padding_left=0 \
        icon.padding_right=0 \
        padding_left=0 \
        padding_right=0 \
        drawing=off \
        click_script="aerospace workspace $sid"
    space_items+=("space.$sid.app.$slot")
  done

  sketchybar --add item "space.$sid.pad.right" center \
    --set "space.$sid.pad.right" icon.drawing=off label.drawing=off \
      width=7 \
      padding_left=0 \
      padding_right=0 \
      drawing=off \
      click_script="aerospace workspace $sid"
  space_items+=("space.$sid.pad.right")

  sketchybar --add item "space.$sid.gap" center \
    --set "space.$sid.gap" icon.drawing=off label.drawing=off \
      width=6 \
      padding_left=0 \
      padding_right=0 \
      drawing=off
  space_items+=("space.$sid.gap")
done

sketchybar --set space.0 padding_left=4 \
           --set space.9 padding_right=4

sketchybar --add bracket spaces.pill "${space_items[@]}" \
  --set spaces.pill "${pill_bg[@]}"

for sid in 0 1 2 3 4 5 6 7 8 9; do
  sketchybar --add bracket "space.$sid.highlight" "space.$sid" \
    "space.$sid.app.1" "space.$sid.app.2" "space.$sid.app.3" "space.$sid.app.4" "space.$sid.app.5" "space.$sid.pad.right" \
    --set "space.$sid.highlight" \
      drawing=off \
      background.drawing=on \
      background.color=$SELECTED \
      background.height=28 \
      background.corner_radius=6 \
      background.border_width=0
done

sketchybar --add event aerospace_workspace_change
sketchybar --add item spaces.listener center \
  --set spaces.listener drawing=off updates=on script="$PLUGIN_DIR/spaces.sh" \
  --subscribe spaces.listener aerospace_workspace_change

sketchybar --add item wifi right \
  --set wifi icon="󰖩" label.drawing=off "${pill_item[@]}" \
    icon.font="Symbols Nerd Font:Regular:14.0" \
    icon.color=$ACCENT_TEXT \
    script="$PLUGIN_DIR/wifi.sh" update_freq=20 \
  --add bracket wifi.pill wifi \
  --set wifi.pill "${pill_bg[@]}" background.color=$WIFI background.border_color=$WIFI_BORDER

sketchybar --add item rhs.gap.wifi_volume right \
  --set rhs.gap.wifi_volume icon.drawing=off label.drawing=off width=4 \
    padding_left=0 padding_right=0

sketchybar --add item volume right \
  --set volume icon="󰕾" label="--%" "${pill_item[@]}" \
    icon.font="Symbols Nerd Font:Regular:14.0" \
    icon.color=$ACCENT_TEXT \
    label.color=$ACCENT_TEXT \
    script="$PLUGIN_DIR/volume.sh" \
  --subscribe volume volume_change \
  --add bracket volume.pill volume \
  --set volume.pill "${pill_bg[@]}" background.color=$VOLUME background.border_color=$VOLUME_BORDER

sketchybar --add item rhs.gap.volume_battery right \
  --set rhs.gap.volume_battery icon.drawing=off label.drawing=off width=4 \
    padding_left=0 padding_right=0

sketchybar --add item battery right \
  --set battery icon="󰁹" label="--%" "${pill_item[@]}" \
    icon.font="Symbols Nerd Font:Regular:14.0" \
    icon.color=$ACCENT_TEXT \
    label.color=$ACCENT_TEXT \
    script="$PLUGIN_DIR/battery.sh" update_freq=30 \
  --add bracket battery.pill battery \
  --set battery.pill "${pill_bg[@]}" background.color=$BATTERY background.border_color=$BATTERY_BORDER

sketchybar --add item rhs.gap.battery_time right \
  --set rhs.gap.battery_time icon.drawing=off label.drawing=off width=4 \
    padding_left=0 padding_right=0

sketchybar --add item date right \
  --set date icon.drawing=off label="Tue Jul 7" "${pill_item[@]}" \
    label.color=$ACCENT_TEXT \
    label.padding_left=12 \
    label.padding_right=10 \
    script="$PLUGIN_DIR/clock.sh" update_freq=5 \
  --add item clock right \
  --set clock icon.drawing=off label="11:22 AM" "${pill_item[@]}" \
    label.color=$ACCENT_TEXT \
    label.padding_left=10 \
    label.padding_right=12 \
  --add bracket time.pill date clock \
  --set time.pill "${pill_bg[@]}" background.color=$TIME background.border_color=$TIME_BORDER

rm -f "${TMPDIR:-/tmp}/sketchybar-aerospace-spaces.state"
sketchybar --trigger aerospace_workspace_change
sketchybar --update

{ ... }:
{
  flake.darwinModules.display.sketchybar =
    { config, lib, pkgs, ... }:
    let
      palette = config.home-manager.users.${config.system.primaryUser}.colorScheme.palette;
      alpha = opacity: base: "0x${opacity}${palette.${base}}";
      colors = {
        surface = alpha "cc" "base01";
        text = alpha "ff" "base07";
        border = alpha "dd" "base03";
        selected = alpha "ff" "base0D";
        selectedText = alpha "ff" "base00";
        accent = alpha "ff" "base0C";
        frontApp = "0x00000000";
        wifi = "0x00000000";
        battery = "0x00000000";
        time = "0x00000000";
        frontAppBorder = alpha "ff" "base08";
        wifiBorder = alpha "ff" "base0B";
        batteryBorder = alpha "ff" "base0A";
        timeBorder = alpha "ff" "base0E";
        accentText = alpha "ff" "base07";
        batteryAccent = alpha "ff" "base0A";
        wifiAccent = alpha "ff" "base0B";
      };
      iconDir = ../../../../.assets/sketchybar-icons;
      configDir = pkgs.runCommand "sketchybar-pill-config" { } ''
        mkdir -p $out/plugins

        cat > $out/plugins/front_app.sh <<'EOF'
#!/bin/sh
PATH="@sketchybar@/bin:/usr/bin:/bin"
export PATH

if [ -n "$INFO" ]; then
  app="$INFO"
else
  app="$(osascript -e 'tell application "System Events" to name of first application process whose frontmost is true' 2>/dev/null)"
fi

sketchybar --set front_app label="$app"
EOF

        cat > $out/plugins/spaces.sh <<'EOF'
#!/bin/sh
PATH="@sketchybar@/bin:@aerospace@/bin:/usr/bin:/bin"
export PATH

focused="$FOCUSED_WORKSPACE"
if [ -z "$focused" ]; then
  focused="$(aerospace list-workspaces --focused 2>/dev/null)"
fi

state_file="''${TMPDIR:-/tmp}/sketchybar-aerospace-spaces.state"
state="focused=$focused"

image_for_app() {
  case "$1" in
    "Google Chrome") printf "@iconDir@/google-chrome.png" ;;
    "Slack") printf "@iconDir@/slack.png" ;;
    "kitty") printf "@iconDir@/kitty.png" ;;
    *) return 1 ;;
  esac
}

for sid in 0 1 2 3 4 5 6 7 8 9; do
  apps=""

  while IFS= read -r app; do
    [ -z "$app" ] && continue
    apps="$apps,$app"
  done <<APPS
$(aerospace list-windows --workspace "$sid" 2>/dev/null | awk -F '|' '{ app=$2; gsub(/^[ \t]+|[ \t]+$/, "", app); if (app != "") print app }')
APPS

  state="$state|$sid:$apps"
done

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
  done <<APPS
$(aerospace list-windows --workspace "$sid" 2>/dev/null | awk -F '|' '{ app=$2; gsub(/^[ \t]+|[ \t]+$/, "", app); if (app != "") print app }')
APPS

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
EOF

        cat > $out/plugins/battery.sh <<'EOF'
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
EOF

        cat > $out/plugins/wifi.sh <<'EOF'
#!/bin/sh
PATH="@sketchybar@/bin:/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources:/usr/sbin:/usr/bin:/bin"
export PATH

network="$(ipconfig getsummary en0 2>/dev/null | awk -F ' SSID : ' '/ SSID : / { print $2; exit }')"

if [ -n "$network" ]; then
  sketchybar --set wifi icon="󰖩" label.drawing=off
else
  sketchybar --set wifi icon="󰖪" label.drawing=off
fi
EOF

        cat > $out/plugins/clock.sh <<'EOF'
#!/bin/sh
PATH="@sketchybar@/bin:/usr/bin:/bin"
export PATH

sketchybar --set date label="$(date '+%a %b %-d')" \
           --set clock label="$(date '+%-I:%M %p')"
EOF

        cat > $out/sketchybarrc <<'EOF'
#!@zsh@/bin/zsh

PATH="@sketchybar@/bin:@aerospace@/bin:/usr/bin:/bin"
export PATH

PLUGIN_DIR="@pluginDir@"

SURFACE=@surface@
TEXT=@text@
BORDER=@border@
ACCENT=@accent@
FRONT_APP=@frontApp@
WIFI=@wifi@
BATTERY=@battery@
TIME=@time@
FRONT_APP_BORDER=@frontAppBorder@
WIFI_BORDER=@wifiBorder@
BATTERY_BORDER=@batteryBorder@
TIME_BORDER=@timeBorder@
ACCENT_TEXT=@accentText@
SELECTED=@selected@
BATTERY_ACCENT=@batteryAccent@
WIFI_ACCENT=@wifiAccent@

pill_bg=(
  background.drawing=on
  background.color=$SURFACE
  background.border_color=$BORDER
  background.border_width=2
  background.corner_radius=9
  background.height=34
)

pill_item=(
  icon.font="SF Pro:Semibold:12.0"
  icon.color=$TEXT
  label.font="SF Pro:Semibold:12.0"
  label.color=$TEXT
  icon.padding_left=8
  icon.padding_right=5
  label.padding_left=0
  label.padding_right=8
  padding_left=0
  padding_right=0
)

sketchybar --bar \
  position=top \
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
  icon.font="SF Pro:Semibold:12.0" \
  label.font="SF Pro:Semibold:12.0" \
  icon.color=$TEXT \
  label.color=$TEXT \
  icon.padding_left=7 \
  icon.padding_right=5 \
  label.padding_left=0 \
  label.padding_right=7

sketchybar --add item front_app left \
  --set front_app icon.drawing=off label="Finder" "''${pill_item[@]}" \
    label.color=$ACCENT_TEXT \
    label.padding_left=12 \
    label.padding_right=12 \
    script="$PLUGIN_DIR/front_app.sh" \
  --subscribe front_app front_app_switched \
  --add bracket front_app.pill front_app \
  --set front_app.pill "''${pill_bg[@]}" background.color=$FRONT_APP background.border_color=$FRONT_APP_BORDER

space_items=()
for sid in 0 1 2 3 4 5 6 7 8 9; do
  sketchybar --add item "space.$sid" center \
    --set "space.$sid" icon="$sid" label="" "''${pill_item[@]}" \
      width=20 \
      icon.font="SF Pro:Semibold:12.0" \
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

sketchybar --add bracket spaces.pill "''${space_items[@]}" \
  --set spaces.pill "''${pill_bg[@]}" background.color=0x00000000

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
  --set wifi icon="󰖩" label.drawing=off "''${pill_item[@]}" \
    icon.font="Symbols Nerd Font:Regular:14.0" \
    icon.color=$ACCENT_TEXT \
    script="$PLUGIN_DIR/wifi.sh" update_freq=20 \
  --add bracket wifi.pill wifi \
  --set wifi.pill "''${pill_bg[@]}" background.color=$WIFI background.border_color=$WIFI_BORDER

sketchybar --add item rhs.gap.wifi_battery right \
  --set rhs.gap.wifi_battery icon.drawing=off label.drawing=off width=4 \
    padding_left=0 padding_right=0

sketchybar --add item battery right \
  --set battery icon="󰁹" label="--%" "''${pill_item[@]}" \
    icon.font="Symbols Nerd Font:Regular:14.0" \
    icon.color=$ACCENT_TEXT \
    label.color=$ACCENT_TEXT \
    script="$PLUGIN_DIR/battery.sh" update_freq=30 \
  --add bracket battery.pill battery \
  --set battery.pill "''${pill_bg[@]}" background.color=$BATTERY background.border_color=$BATTERY_BORDER

sketchybar --add item rhs.gap.battery_time right \
  --set rhs.gap.battery_time icon.drawing=off label.drawing=off width=4 \
    padding_left=0 padding_right=0

sketchybar --add item date right \
  --set date icon.drawing=off label="Tue Jul 7" "''${pill_item[@]}" \
    label.color=$ACCENT_TEXT \
    label.padding_left=12 \
    label.padding_right=10 \
    script="$PLUGIN_DIR/clock.sh" update_freq=30 \
  --add item clock right \
  --set clock icon.drawing=off label="11:22 AM" "''${pill_item[@]}" \
    label.color=$ACCENT_TEXT \
    label.padding_left=10 \
    label.padding_right=12 \
  --add bracket time.pill date clock \
  --set time.pill "''${pill_bg[@]}" background.color=$TIME background.border_color=$TIME_BORDER

rm -f "''${TMPDIR:-/tmp}/sketchybar-aerospace-spaces.state"
sketchybar --trigger aerospace_workspace_change
sketchybar --update
EOF

        substituteInPlace $out/sketchybarrc \
          --replace "@pluginDir@" "$out/plugins" \
          --replace "@zsh@" "${pkgs.zsh}" \
          --replace "@sketchybar@" "${pkgs.sketchybar}" \
          --replace "@aerospace@" "${pkgs.aerospace}" \
          --replace "@iconDir@" "${iconDir}" \
          --replace "@surface@" "${colors.surface}" \
          --replace "@text@" "${colors.text}" \
          --replace "@border@" "${colors.border}" \
          --replace "@selected@" "${colors.selected}" \
          --replace "@selectedText@" "${colors.selectedText}" \
          --replace "@accent@" "${colors.accent}" \
          --replace "@frontApp@" "${colors.frontApp}" \
          --replace "@wifi@" "${colors.wifi}" \
          --replace "@battery@" "${colors.battery}" \
          --replace "@time@" "${colors.time}" \
          --replace "@frontAppBorder@" "${colors.frontAppBorder}" \
          --replace "@wifiBorder@" "${colors.wifiBorder}" \
          --replace "@batteryBorder@" "${colors.batteryBorder}" \
          --replace "@timeBorder@" "${colors.timeBorder}" \
          --replace "@accentText@" "${colors.accentText}" \
          --replace "@batteryAccent@" "${colors.batteryAccent}" \
          --replace "@wifiAccent@" "${colors.wifiAccent}"
        substituteInPlace $out/plugins/*.sh \
          --replace "@sketchybar@" "${pkgs.sketchybar}" \
          --replace "@aerospace@" "${pkgs.aerospace}" \
          --replace "@iconDir@" "${iconDir}" \
          --replace "@text@" "${colors.text}" \
          --replace "@selected@" "${colors.selected}" \
          --replace "@selectedText@" "${colors.selectedText}"
        chmod +x $out/sketchybarrc $out/plugins/*.sh
      '';
    in
    {
      config = {
        environment.systemPackages = with pkgs; [
          sketchybar
          nerd-fonts.symbols-only
        ];

        system.defaults.NSGlobalDomain._HIHideMenuBar = true;

        services.aerospace.settings.exec-on-workspace-change = lib.mkAfter [
          "${pkgs.bash}/bin/bash"
          "-c"
          "${pkgs.sketchybar}/bin/sketchybar --trigger aerospace_workspace_change FOCUSED_WORKSPACE=$AEROSPACE_FOCUSED_WORKSPACE PREV_WORKSPACE=$AEROSPACE_PREV_WORKSPACE"
        ];

        services.aerospace.settings.on-focus-changed = lib.mkAfter [
          "exec-and-forget ${pkgs.sketchybar}/bin/sketchybar --trigger aerospace_workspace_change"
        ];

        services.aerospace.settings.on-window-detected = lib.mkAfter [
          {
            run = "exec-and-forget ${pkgs.sketchybar}/bin/sketchybar --trigger aerospace_workspace_change";
          }
        ];

        launchd.user.agents.sketchybar = {
          serviceConfig = {
            ProgramArguments = [
              "${pkgs.sketchybar}/bin/sketchybar"
              "--config"
              "${configDir}/sketchybarrc"
            ];
            KeepAlive = true;
            RunAtLoad = true;
            StandardOutPath = "/tmp/sketchybar.out.log";
            StandardErrorPath = "/tmp/sketchybar.err.log";
          };
        };
      };
    };
}

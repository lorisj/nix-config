{ inputs, ... }:
{
  flake.homeModules.waybar =
    { pkgs, lib, config, ... }:
    let
      colors = config.colorScheme.palette;
    in
    {
      config = lib.mkIf (pkgs.stdenv.hostPlatform.isLinux && config.wm.hyprland.enable) {
        programs.waybar = {
          enable = true;
          style = inputs.nix-helpers.lib.replace-by-set { inherit lib; } colors (
            builtins.readFile ./style.css
          );
          settings = [
            {
              "layer" = "top";
              "position" = "bottom";
              "height" = 32;
              "width" = 1020;
              "modules-left" = [
                "hyprland/workspaces"
                "hyprland/window"
              ];
              "modules-right" = [
                "tray"
                "pulseaudio"
                "network"
                "cpu"
                "memory"
                "temperature"
                "custom/wireguard"
                "battery"
                "clock"
              ];
              "hyprland/workspaces" = {
                "disable-scroll" = true;
                "disable-markup" = false;
                "all-outputs" = true;
                "format" = "  {icon}  ";
                "format-icons" = {
                  "focused" = "Cur";
                  "default" = "◯";
                };
              };
              "clock" = {
                "format" = "{:%a, %m/%d    <b>%R </b>}";
              };
              "cpu" = {
                "format" = "{usage}% ";
              };
              "memory" = {
                "format" = "{}% ";
              };
              "temperature" = {
                "critical-threshold" = 80;
                "format-critical" = "{temperatureC}°C ";
                "format" = "{temperatureC}°C ";
              };
              "custom/wireguard" = {
                "exec" = "~/scripts/get-vpn-name";
                "interval" = 3;
                "return-type" = "text";
                "format" = "{}";
              };
              "battery" = {
                "states" = {
                  "good" = 95;
                  "warning" = 30;
                  "critical" = 15;
                };
                "format" = "{capacity}% {icon}";
                "format-icons" = [
                  ""
                  ""
                  ""
                  ""
                  ""
                ];
              };
              "network" = {
                "format-wifi" = "{essid} ({signalStrength}%) ";
                "format-ethernet" = "{ifname}: {ipaddr}/{cidr} ";
                "format-disconnected" = "Disconnected ⚠";
                "interval" = 7;
                "on-click" = "nm-connection-editor";
              };
              "pulseaudio" = {
                "format" = "{volume}% {icon}";
                "format-bluetooth" = "{volume}% {icon}";
                "format-muted" = "";
                "format-icons" = {
                  "headphones" = "";
                  "handsfree" = "";
                  "headset" = "";
                  "phone" = "";
                  "portable" = "";
                  "car" = "";
                  "default" = [
                    ""
                    ""
                  ];
                };
                "on-click" = "pavucontrol";
              };
            }
          ];
        };
      };
    };
}

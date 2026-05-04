{ ... }:
{
  flake.homeModules.wm.hyprland =
    { pkgs, lib, osConfig, ... }:
    let
      displayScaling = lib.attrByPath [
        "os"
        "display"
        "hyprland"
        "displayScaling"
      ] 1 osConfig;
    in
    {
      config = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
        wayland.windowManager.hyprland = {
          enable = true;
          package = null;
          portalPackage = null;
          xwayland.enable = true;
          settings = {
            "$mod" = "super";
            "$terminal" = "kitty";
            "$fileManager" = "thunar";
            "$menu" = "wofi --show drun";
            monitor = [
              ",preferred,auto,${builtins.toString displayScaling}"
            ];
            exec-once = [
              "${pkgs.waybar}/bin/waybar"
            ];
          };
          plugins = [
            pkgs.hyprlandPlugins.hy3
          ];
        };
      };
    };
}

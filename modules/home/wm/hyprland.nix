{ ... }:
{
  flake.homeModules.wm.hyprland =
    { pkgs, lib, osConfig, config, ... }:
    {
      options.wm.hyprland.enable = lib.mkOption {
        type = lib.types.bool;
        readOnly = true;
        default = lib.attrByPath [
          "os"
          "display"
          "hyprland"
          "enabled"
        ] false osConfig;
        description = "Mirrors NixOS `os.display.hyprland.enabled` from `osConfig` when Home Manager runs on NixOS.";
      };

      options.wm.hyprland.displayScaling = lib.mkOption {
        type = lib.types.int;
        readOnly = true;
        default = lib.attrByPath [
          "os"
          "display"
          "hyprland"
          "displayScaling"
        ] 1 osConfig;
        description = "Mirrors NixOS `os.display.hyprland.displayScaling` from `osConfig`.";
      };

      config = lib.mkIf (pkgs.stdenv.hostPlatform.isLinux && config.wm.hyprland.enable) {
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
              ",preferred,auto,${builtins.toString config.wm.hyprland.displayScaling}"
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

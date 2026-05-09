{ ... }:
{
  flake.homeModules.wm.hyprland.decoration =
    { pkgs, lib, config, ... }:
    {
      config = lib.mkIf (pkgs.stdenv.hostPlatform.isLinux && config.wm.hyprland.enable) {
        wayland.windowManager.hyprland.settings = {
          decoration = {
            rounding = 15;
            active_opacity = 0.95;
            inactive_opacity = 0.8;
            fullscreen_opacity = 0.99;
          };

          animations = {
            enabled = true;
            bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
            animation = [
              "windows, 1, 6, myBezier"
              "windowsOut, 1, 7, default, popin 80%"
              "border, 1, 10, default"
              "borderangle, 1, 8, default"
              "fade, 1, 7, default"
              "workspaces, 1, 6, default"
            ];
          };
        };
      };
    };
}

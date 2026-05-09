{ ... }:
{
  flake.homeModules.wm.hyprland.hyprlock =
    { config, lib, pkgs, ... }:
    {
      config = lib.mkIf (pkgs.stdenv.hostPlatform.isLinux && config.wm.hyprland.enable) {
        programs.hyprlock = {
          enable = true;
          settings = {
            general = {
              hide_cursor = true;
            };
            background = [
              {
                path = builtins.toString config.wallpaperPath;
                blur_passes = 3;
                blur_size = 8;
              }
            ];
            "input-field" = [
              {
                size = "200, 50";
                position = "0, -80";
                monitor = "";
                dots_center = true;
                fade_on_empty = false;
                font_color = "rgb(202, 211, 245)";
                inner_color = "rgb(91, 96, 120)";
                outer_color = "rgb(24, 25, 38)";
                outline_thickness = 5;
                placeholder_text = "Password...";
                shadow_passes = 2;
              }
            ];
          };
        };
      };
    };
}

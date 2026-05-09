{ inputs, ... }:
{
  flake.homeModules.wm.rofi =
    { config, lib, pkgs, ... }:
    let
      cssContent = builtins.readFile ./style.css;
      style = inputs.nix-helpers.lib.replace-by-set { inherit lib; } config.colorScheme.palette cssContent;
    in
    {
      config = lib.mkIf (pkgs.stdenv.hostPlatform.isLinux && config.wm.hyprland.enable) {
        programs.wofi = {
          enable = true;
          settings = {
            show = "drun";
            location = "center";
            width = 800;
            height = 700;
            image_size = 40;
            allow_images = true;
            insensitive = true;
            prompt = "Search:";
          };
          style = style;
        };
      };
    };
}

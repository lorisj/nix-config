{ ... }:
{
  flake.homeModules.wm.hyprland.hyprshot =
    { config, lib, pkgs, ... }:
    {
      config = lib.mkIf (pkgs.stdenv.hostPlatform.isLinux && config.wm.hyprland.enable) {
        programs.hyprshot = {
          enable = true;
          saveLocation = "$HOME/screenshots";
        };
      };
    };
}

{ lib, ... }:
{
  flake.homeModules.programs.firefox =
    { config, ... }:
    {
      config = lib.mkIf config.wm.hyprland.enable {
        programs.firefox.enable = true;
      };
    };
}

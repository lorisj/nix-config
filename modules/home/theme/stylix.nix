{ ... }:
{

  flake.homeModules.theme.stylix =
    { config, lib, ... }:
    {
      config = {
        stylix.base16Scheme = config.colorScheme.palette;
        stylix.image = config.wallpaperPath;
        stylix.targets.hyprlock.enable = false;
        stylix.targets.dunst.enable = true;
        # The launcher uses Wofi; avoid configuring the unused Rofi target.
        stylix.targets.rofi.enable = false;
        # stylix.targets.firefox.profileNames = [ "default" ];
        # stylix.targets.firefox.enable = true;
        # stylix.targets.firefox.colorTheme.enable = true;
      };
    };

}

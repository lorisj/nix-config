{ flake, ... }:
{

  flake.homeModules.stylix =
    { config, lib, ... }:
    {
      options = {
        wallpaperPath = lib.mkOption {
          description = "Path to wallpaper to use w/ stylix";
          type = lib.types.path;
        };
      };
      config = {
        stylix.base16Scheme = config.colorScheme.palette;
        stylix.image = config.wallpaperPath;
        stylix.targets.hyprlock.enable = false;
        stylix.targets.dunst.enable = true;
        # stylix.targets.firefox.profileNames = [ "default" ];
        # stylix.targets.firefox.enable = true;
        # stylix.targets.firefox.colorTheme.enable = true;
      };
    };

}

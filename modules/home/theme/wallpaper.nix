{ ... }:
{
  flake.homeModules.wallpaper =
    { lib, ... }:
    {
      options.wallpaperPath = lib.mkOption {
        type = lib.types.path;
        description = "Path to the wallpaper image (e.g. macOS desktop picture, stylix.image).";
      };
    };
}

{ ... }:
{
  flake.homeModules.theme.wallpaper =
    { config, lib, pkgs, ... }:
    let
      cfg = config.macosDesktopWallpaper;
    in
    {
      options = {
        wallpaperPath = lib.mkOption {
          type = lib.types.path;
          description = "Path to the wallpaper image (e.g. macOS desktop picture, stylix.image).";
        };

        macosDesktopWallpaper = {
          enable = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = ''
              On macOS only: run home-manager activation to set the desktop picture
              from `wallpaperPath`.

              Default is `true`, so this activation runs on Darwin by default; set
              to `false` to skip.
            '';
          };
        };
      };

      config = lib.mkIf (pkgs.stdenv.hostPlatform.isDarwin && cfg.enable) {
        home.activation.setMacosDesktopWallpaper = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          /usr/bin/osascript -e 'tell application "System Events" to tell every desktop to set picture to POSIX file "${toString config.wallpaperPath}"'
        '';
      };
    };
}

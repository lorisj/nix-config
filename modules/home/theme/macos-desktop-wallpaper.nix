{ flake, ... }:
{
  flake.homeModules.macos-desktop-wallpaper =
    { config, lib, pkgs, ... }:
    let
      cfg = config.macosDesktopWallpaper;
    in
    {
      options.macosDesktopWallpaper = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = ''
            When enabled on macOS, set the desktop picture from wallpaperPath on
            home-manager activation.
          '';
        };
      };

      config = lib.mkIf (pkgs.stdenv.hostPlatform.isDarwin && cfg.enable) {
        home.activation.setMacosDesktopWallpaper = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          /usr/bin/osascript -e 'tell application "System Events" to tell every desktop to set picture to POSIX file "${toString config.wallpaperPath}"'
        '';
      };
    };
}

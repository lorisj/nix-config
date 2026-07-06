{ ... }:
{
  flake.homeModules.wm.jankyborders =
    { lib, pkgs, ... }:
    {
      config = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
        services.jankyborders = {
          enable = true;
          settings = {
            style = "round";
            width = 3.0;
            hidpi = "on";
            active_color = "0x66494d64";
            inactive_color = "0x33494d64";
          };
        };
      };
    };
}

{ ... }:
{
  flake.osModules.display.steam =
    { config, pkgs, lib, ... }:
    let
      cfg = config.os.display.steam;
      bigPicture = pkgs.writeShellScript "steam-bigpicture" ''
        exec ${lib.getExe pkgs.gamescope} --steam -e \
          -W ${toString cfg.width} -H ${toString cfg.height} \
          -- steam -tenfoot -pipewire-dmabuf
      '';
    in
    {
      options = {
        os.display.steam.enabled = lib.mkEnableOption "steam big picture session";
        os.display.steam.user = lib.mkOption {
          type = lib.types.str;
          default = "steam";
          description = "Kiosk account auto-logged into the gamescope Steam session.";
        };
        os.display.steam.width = lib.mkOption { type = lib.types.int; default = 1920; };
        os.display.steam.height = lib.mkOption { type = lib.types.int; default = 1080; };
      };

      config = lib.mkIf cfg.enabled {
        nixpkgs.config.allowUnfree = true;

        programs.steam = {
          enable = true;
          gamescopeSession.enable = true;
          remotePlay.openFirewall = true;
          localNetworkGameTransfers.openFirewall = true;
        };
        programs.gamescope = {
          enable = true;
          capSysNice = true;
        };
        programs.gamemode.enable = true;
        hardware.steam-hardware.enable = true;

        hardware.graphics.enable = true;
        hardware.graphics.enable32Bit = true;

        services.pipewire = {
          enable = true;
          alsa.enable = true;
          alsa.support32Bit = true;
          pulse.enable = true;
        };

        services.greetd = {
          enable = true;
          settings.initial_session = {
            command = "${bigPicture}";
            user = cfg.user;
          };
          settings.default_session = {
            command = "${lib.getExe pkgs.tuigreet} --time --remember";
            user = "greeter";
          };
        };
      };
    };
}

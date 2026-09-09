{ ... }:
{
  flake.osModules.display.steam =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      cfg = config.os.display.steam;
      nestedSteam = pkgs.writeShellScript "steam-nested-gamescope" ''
        exec ${lib.getExe pkgs.gamescope} --backend wayland --steam -e -f \
          --hide-cursor-delay 1000 \
          -w ${toString cfg.width} -h ${toString cfg.height} \
          -W ${toString cfg.width} -H ${toString cfg.height} -r 60 \
          -- steam -tenfoot -pipewire-dmabuf
      '';
      bigPicture = pkgs.writeShellScript "steam-bigpicture" ''
        exec ${lib.getExe config.programs.hyprland.package}
      '';
    in
    {
      options = {
        os.display.steam.enabled = lib.mkEnableOption "steam big picture session";
        os.display.steam.user = lib.mkOption {
          type = lib.types.str;
          default = "steam";
          description = "Kiosk account auto-logged into the Steam session.";
        };
        os.display.steam.width = lib.mkOption {
          type = lib.types.int;
          default = 1920;
        };
        os.display.steam.height = lib.mkOption {
          type = lib.types.int;
          default = 1080;
        };
      };

      config = lib.mkIf cfg.enabled {
        nixpkgs.config.allowUnfree = true;

        programs.steam = {
          enable = true;
          gamescopeSession.enable = false;
          remotePlay.openFirewall = true;
          localNetworkGameTransfers.openFirewall = true;
        };
        programs.gamescope = {
          enable = true;
          capSysNice = false;
        };
        programs.hyprland = {
          enable = true;
          xwayland.enable = true;
        };
        home-manager.users.${cfg.user} = {
          config.wayland.windowManager.hyprland = {
            enable = true;
            configType = "hyprlang";
            package = null;
            portalPackage = null;
            settings = {
              monitor = [
                ",${toString cfg.width}x${toString cfg.height}@60,auto,1"
              ];
              cursor = {
                inactive_timeout = 1;
                hide_on_key_press = true;
              };
              exec-once = [ "${nestedSteam}" ];
              bind = [
                "SUPER, F, fullscreen"
                "SUPER SHIFT, E, exit"
              ];
            };
          };
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

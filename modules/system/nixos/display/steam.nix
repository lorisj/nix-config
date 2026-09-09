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
      nestedGamescope = cfg.session == "hyprland-gamescope";
      useHyprland = cfg.session != "gamescope";
      nestedSteam = pkgs.writeShellScript "steam-nested-gamescope" ''
        exec ${lib.getExe pkgs.gamescope} --backend wayland --steam -e -f \
          -w ${toString cfg.width} -h ${toString cfg.height} \
          -W ${toString cfg.width} -H ${toString cfg.height} -r 60 \
          -- steam -tenfoot -pipewire-dmabuf
      '';
      hyprlandConfig = pkgs.writeText "steam-hyprland.conf" ''
        monitor = ,${toString cfg.width}x${toString cfg.height}@60,auto,1
        exec-once = ${if nestedGamescope then nestedSteam else "steam -tenfoot"}
        bind = SUPER, F, fullscreen
        bind = SUPER SHIFT, E, exit
      '';
      bigPicture = pkgs.writeShellScript "steam-bigpicture" (
        if useHyprland then
          ''
            exec ${lib.getExe config.programs.hyprland.package} --config ${hyprlandConfig}
          ''
        else
          ''
            exec ${lib.getExe pkgs.gamescope} --steam -e \
              -W ${toString cfg.width} -H ${toString cfg.height} \
              -- steam -tenfoot -pipewire-dmabuf
          ''
      );
    in
    {
      options = {
        os.display.steam.enabled = lib.mkEnableOption "steam big picture session";
        os.display.steam.session = lib.mkOption {
          type = lib.types.enum [ "gamescope" "hyprland" "hyprland-gamescope" ];
          default = "gamescope";
          description = "Steam kiosk session: standalone Gamescope, Hyprland, or Gamescope nested inside Hyprland. Hyprland sessions use 60 Hz output.";
        };
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
          gamescopeSession.enable = cfg.session == "gamescope";
          remotePlay.openFirewall = true;
          localNetworkGameTransfers.openFirewall = true;
        };
        programs.gamescope = {
          enable = cfg.session == "gamescope" || nestedGamescope;
          capSysNice = cfg.session == "gamescope";
        };
        programs.hyprland = lib.mkIf useHyprland {
          enable = true;
          xwayland.enable = true;
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

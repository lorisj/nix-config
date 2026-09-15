{ ... }:
{
  flake.osModules.games.minecraft =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.os.games.minecraft;
    in
    {
      options.os.games.minecraft = {
        enabled = lib.mkEnableOption "a manually installed Forge Minecraft server (accepts the Minecraft EULA)";

        port = lib.mkOption {
          type = lib.types.port;
          default = 25565;
          description = "Minecraft server TCP port, also opened in the firewall.";
        };

        javaPackage = lib.mkOption {
          type = lib.types.package;
          default = pkgs.jdk17;
          defaultText = lib.literalExpression "pkgs.jdk17";
          description = "Java package matching the installed Forge version. Java 17 suits Minecraft 1.18–1.20.4; newer packs may need Java 21 or later.";
        };
      };

      config = lib.mkIf cfg.enabled {
        # Also make Java available for running the Forge installer manually.
        environment.systemPackages = [ cfg.javaPackage ];

        services.minecraft-server = {
          enable = true;
          eula = true;
          declarative = true;
          serverProperties.server-port = cfg.port;

          # Forge reads JVM flags from user_jvm_args.txt in the server directory.
          jvmOpts = "";
          package = pkgs.writeShellScriptBin "minecraft-server" ''
            exec ${pkgs.bash}/bin/bash ./run.sh nogui
          '';
        };

        systemd.services.minecraft-server = {
          path = [ cfg.javaPackage ];
          # The first rebuild creates the service user and data directory;
          # start the service after installing Forge and copying the mods.
          unitConfig.ConditionPathExists = "${config.services.minecraft-server.dataDir}/run.sh";
          serviceConfig.TimeoutStopSec = "2min";
        };

        networking.firewall.allowedTCPPorts = [ cfg.port ];
      };
    };
}

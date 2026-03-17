{ ... }:
{
  flake.darwinModules.display.swiftbar =
    { pkgs, ... }:
    let
      refreshInterval = "5s";

      caltrainPlugin = pkgs.replaceVarsWith {
        src = ./plugins/caltrain.js;
        isExecutable = true;
        replacements = {
          node = "${pkgs.nodejs}/bin/node";
        };
      };

      pluginDir = pkgs.runCommand "swiftbar-plugins" { } ''
        mkdir -p $out
        cat > $out/caltrain.${refreshInterval}.sh <<WRAPPER
#!/bin/sh
exec ${caltrainPlugin}
WRAPPER
        chmod +x $out/caltrain.${refreshInterval}.sh
      '';
    in
    {
      environment.systemPackages = with pkgs; [
        swiftbar
      ];
      system.defaults.CustomUserPreferences."com.ameba.SwiftBar" = {
        PluginDirectory = "${pluginDir}";
        # if this is not set, swiftbar will display "Session Restored ..."
        Shell = "zsh";
      };
      launchd.user.agents.swiftbar = {
        serviceConfig = {
          ProgramArguments = [ "${pkgs.swiftbar}/bin/SwiftBar" ];
          KeepAlive = true;
          RunAtLoad = true;
        };
      };
    };
}

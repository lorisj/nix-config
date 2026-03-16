{ inputs, ... }:
{
  flake.darwinModules.display.swiftbar =
    { pkgs, ... }:
    let
      # if this is not done, then test.sh will not have exe priv in nix store.
      pluginDir = pkgs.runCommand "swiftbar-plugins" { } ''
        mkdir -p $out
        cp ${./plugins/test.sh} $out/test.1s.sh
        chmod +x $out/test.1s.sh
      '';
    in
    {
      environment.systemPackages = with pkgs; [
        swiftbar
      ];
      system.defaults.CustomUserPreferences."com.ameba.SwiftBar" = {
        PluginDirectory = "${pluginDir}";
      };
    };
}

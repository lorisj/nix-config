{ lib, self, ... }:
let
  runners = {
    x86_64-linux = "ubuntu-24.04";
    aarch64-linux = "ubuntu-24.04-arm";
    x86_64-darwin = "macos-15-intel";
    aarch64-darwin = "macos-15";
  };

  hostEntries =
    output: buildAttribute:
    lib.mapAttrsToList (
      host: configuration:
      let
        system = configuration.pkgs.stdenv.hostPlatform.system;
      in
      {
        inherit host system;
        runner = runners.${system} or (throw "No GitHub Actions runner configured for ${host} (${system})");
        target = "${output}.${builtins.toJSON host}.${buildAttribute}";
      }
    ) (self.${output} or { });
in
{
  # Discover hosts from the actual flake outputs, including their target platforms.
  flake.ci.matrix.include =
    (hostEntries "nixosConfigurations" "config.system.build.toplevel")
    ++ (hostEntries "darwinConfigurations" "system");
}

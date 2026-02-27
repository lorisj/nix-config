{
  flake,
  self,
  inputs,
  withSystem,
  ...
}:
{
  flake.darwinConfigurations.macbook = inputs.nix-darwin.lib.darwinSystem {
    specialArgs = { inherit inputs; };
    modules = [
      {
        nixpkgs.hostPlatform = "aarch64-darwin";
        ids.gids.nixbld = 350;
        system.stateVersion = 4;
      }
      self.darwinModules.default

      ({ config, ... }: {
        # Use the configured pkgs from perSystem
        nixpkgs.pkgs = withSystem config.nixpkgs.hostPlatform.system (
          { pkgs, ... }: # perSystem module arguments
          pkgs
        );
      })
    ];
  };
}

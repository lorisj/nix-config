{
  flake,
  self,
  inputs,
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
    ];
  };
}

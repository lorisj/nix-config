
{
  flake,
  self,
  inputs,
  ...
}:
{
  flake.nixosConfigurations.laptop = inputs.nixpkgs.lib.nixosSystem {
    specialArgs = { inherit inputs; };
    modules = [
      {
        system = "x86_64-linux";
      }
      self.nixosModules.default
    ];
  };
}

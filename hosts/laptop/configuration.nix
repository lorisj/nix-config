
{
  self,
  inputs,
  ...
}:
{
  flake.nixosConfigurations.laptop = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.hardwareConfigurations.laptop
      self.nixosModules.default
    ];
  };
}

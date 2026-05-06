{
  self,
  inputs,
  ...
}:
{
  imports = [ ./hardware-configuration.nix ];
  flake.nixosConfigurations.laptop = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.nixosModules.hardwareConfigurations.laptop
      self.nixosModules.default
    ];
  };
}

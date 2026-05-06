{
  self,
  inputs,
  ...
}:
{
  imports = [ ./hardware-configuration.nix ];
  flake.nixosConfigurations.laptop = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.osModules.hardwareConfigurations.laptop
      self.osModules.default
    ];
  };
}

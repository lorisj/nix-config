{ inputs, ... }:
{
  flake.nixosModules.home-manager =
    { ... }:
    {
      imports = [
        inputs.home-manager.nixosModules.default
      ];
    };
}

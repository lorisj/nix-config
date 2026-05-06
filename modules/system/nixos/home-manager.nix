{ inputs, ... }:
{
  flake.osModules.home-manager =
    { ... }:
    {
      imports = [
        inputs.home-manager.nixosModules.default
      ];
    };
}

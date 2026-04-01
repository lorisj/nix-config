{
  flake,
  self,
  inputs,
  ...
}:
{
  flake.darwinModules.shared.default =
    { ... }:
    {
      imports = [
        self.darwinModules.shared.theme.stylix
        self.darwinModules.shared.nix.settings
      ];

    };
  flake.nixosModules.shared.default = {
    imports = [
      self.nixosModules.shared.theme.stylix
      self.nixosModules.shared.nix.settings
    ];
  };
}

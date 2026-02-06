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
        self.darwinModules.shared.dockerClient
      ];

    };
  flake.nixosModules.shared.default = {
    imports = [
      self.nixosModules.shared.theme.stylix
      self.nixosModules.shared.nix.settings
      self.nixosModules.shared.dockerClient
    ];
  };
}

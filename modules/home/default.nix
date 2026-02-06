{
  flake,
  self,
  inputs,
  ...
}:
{
  flake.homeModules.default =
    { ... }:
    {
      home.stateVersion = "24.05";
      imports = [
        inputs.nix-colors.homeManagerModules.default
        self.homeModules.vscode
        self.homeModules.cursor
        self.homeModules.git
        self.homeModules.stylix
      ];
    };
}

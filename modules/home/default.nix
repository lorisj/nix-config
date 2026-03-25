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
        self.homeModules.nixvim
        self.homeModules.git
        self.homeModules.direnv
        self.homeModules.stylix
        self.homeModules.shells
        self.homeModules.claude-code
        self.homeModules.lazygit
        self.homeModules.eza
        self.homeModules.kitty
        self.homeModules.starship
      ];
    };
}

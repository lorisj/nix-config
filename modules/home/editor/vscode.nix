{ flake, pkgs, ... }:
{
  flake.homeModules.vscode =
    { ... }:
    {
      programs.vscode = {
        enable = true;
      };
    };
}

{ flake, ... }:
{
  flake.homeModules.vscode =
    { ... }:
    {
      programs.vscode = {
        enable = true;
      };
    };
}

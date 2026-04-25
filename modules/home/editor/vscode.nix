{ ... }:
{
  flake.homeModules.editor.vscode =
    { ... }:
    {
      programs.vscode = {
        enable = true;
      };
    };
}

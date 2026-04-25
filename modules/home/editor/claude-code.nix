{ ... }:
{
  flake.homeModules.editor.claude-code =
    { pkgs, ... }:
    {
      home.packages = [
        pkgs.claude-code
      ];
    };
}


{ ... }:
{
  flake.homeModules.editor.claude-code =
    { pkgs, ... }:
    {
      config = {
        home.packages = [
          pkgs.claude-code
        ];
      };
    };
}


{  ... }:
{
  flake.homeModules.editor.cursor =
    { pkgs, ... }:
    {
      config = {
        home.packages = [
          pkgs.code-cursor
        ];
      };
    };
}

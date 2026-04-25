{  ... }:
{
  flake.homeModules.editor.cursor =
    { pkgs, ... }:
    {

     home.packages = [
        pkgs.code-cursor
    ];
    };
}

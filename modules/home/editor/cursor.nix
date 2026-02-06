{ flake, pkgs, ... }:
{
  flake.homeModules.cursor =
    { pkgs, ... }:
    {
      home.packages = [
        pkgs.code-cursor
      ];
    };
}

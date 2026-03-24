{
  flake,
  lib,
  ...
}:
{
  flake.homeModules.direnv =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      programs.direnv = {
        enable = true;
        enableBashIntegration = true;
        enableZshIntegration = true;
      };

    };
}

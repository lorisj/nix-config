{
  flake,
  lib,
  ...
}:
{
  flake.homeModules.devops.direnv =
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

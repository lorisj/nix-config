{
  flake,
  lib,
  ...
}:
{
  flake.homeModules.direnv =
    { config, lib, ... }: 
    {
      programs.direnv = {
        enable = true;
        enableBashIntegration = true;
        enableZshIntegration = true;
      };

    };
}

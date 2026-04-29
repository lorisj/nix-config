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
      config = {
        programs.direnv = {
          enable = true;
          enableBashIntegration = true;
          enableZshIntegration = true;
        };
      };
    };
}

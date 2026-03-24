{
  flake,
  lib,
  ...
}:
{
  flake.homeModules.direnv =
    { config, lib, pkgs, ... }:
    {
      programs.direnv = {
        enable = true;
        enableBashIntegration = true;
        enableZshIntegration = true;
        package = pkgs.direnv.overrideAttrs (old: {
          env = old.env // {
            CGO_ENABLED = "1";
          };
        });
      };

    };
}

{
  flake,
  lib,
  ...
}:
{
  flake.homeModules.git =
    { config, lib, ... }:
    {
      options.gitConfig = lib.mkOption {
        type = lib.types.submodule {
          options = {
            userName = lib.mkOption {
              type = lib.types.str;
            };
            userEmail = lib.mkOption {
              type = lib.types.str;
            };
          };
        };
      };
      config = {
        programs.git = {
          enable = true;
          settings = {
            user.name = config.gitConfig.userName;
            user.email = config.gitConfig.userEmail;
            init.defaultBranch = "main";
          };
        };
      };
    };
}

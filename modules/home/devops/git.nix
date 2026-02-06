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
          userName = config.gitConfig.userName;
          userEmail = config.gitConfig.userEmail;
          extraConfig.init.defaultBranch = "main";
        };
      };
    };
}

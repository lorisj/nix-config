{ self, ... }:
{
  flake.sharedModules.users =
    { config, lib, ... }:
    {
      options.os.users = lib.mkOption {
        type = lib.types.attrsOf (
          lib.types.submodule {
            options.isAdmin = lib.mkOption {
              type = lib.types.bool;
              default = false;
              description = "Whether this user may administer the host.";
            };
          }
        );
        default = { };
        description = "User profiles enabled on this host.";
      };

      config.assertions = map (userName: {
        assertion = builtins.hasAttr userName self.userConfig;
        message = "os.users.${userName} has no matching flake.userConfig.${userName}";
      }) (lib.attrNames config.os.users);
    };
}

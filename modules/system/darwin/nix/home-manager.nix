{ inputs, ... }:
{
  flake.darwinModules.nix.home-manager =
    { config, lib, ... }:
    let
      userNames = lib.sort lib.lessThan (lib.attrNames config.os.users);
      adminUserNames = builtins.filter (userName: config.os.users.${userName}.isAdmin) userNames;
    in
    {
      imports = [
        inputs.home-manager.darwinModules.home-manager
      ];
      config = {
        system.primaryUser =
          if userNames == [ ] then
            throw "flake.userConfig must name at least one user for darwin"
          else
            builtins.head userNames;

        users.users = builtins.listToAttrs (
          builtins.map (userName: {
            name = userName;
            value = {
              home = "/Users/${userName}";
            };
          }) userNames
        );

        security.sudo.extraConfig = lib.concatMapStringsSep "\n" (
          userName: "${userName} ALL = (ALL) ALL"
        ) adminUserNames;
      };
    };
}

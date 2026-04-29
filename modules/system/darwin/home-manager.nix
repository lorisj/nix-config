{ lib, self, inputs, ... }:
let
  userNames = lib.sort lib.lessThan (lib.attrNames self.userConfig);
in
{
  flake.darwinModules.home-manager =
    { ... }:
    {
      imports = [
        inputs.home-manager.darwinModules.home-manager
      ];

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
    };
}

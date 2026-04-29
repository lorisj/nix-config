{ lib, self, ... }:
{
  flake.sharedModules.nix.home-manager =
    { ... }:
    let
      userNames = lib.sort lib.lessThan (lib.attrNames self.userConfig);
    in
    {
      config = {
        home-manager.useGlobalPkgs = true;
        home-manager.sharedModules = [
          self.homeModules.default
        ];

        home-manager.users = builtins.listToAttrs (
          builtins.map (userName: {
            name = userName;
            value = {
              imports = [
                self.userConfig.${userName}.module
              ];
            };
          }) userNames
        );
      };
    };
}

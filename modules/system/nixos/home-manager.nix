{ inputs, self, ... }:
{
  flake.osModules.home-manager =
    { config, lib, ... }:
    let
      userNames = lib.sort lib.lessThan (lib.attrNames config.os.users);
    in
    {
      imports = [
        inputs.home-manager.nixosModules.default
      ];
      config = {
        users.users = builtins.listToAttrs (
          builtins.map (userName: {
            name = userName;
            value = {
              isNormalUser = true;
              home = "/home/${userName}";
              extraGroups = lib.unique (
                self.userConfig.${userName}.nixos.extraGroups
                ++ lib.optionals config.os.users.${userName}.isAdmin [
                  "docker"
                  "networkmanager"
                  "wheel"
                ]
              );
            };
          }) userNames
        );
      };
    };
}

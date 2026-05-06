{ inputs, lib, self, ... }:
let
  userNames = lib.sort lib.lessThan (lib.attrNames self.userConfig);
in
{
  flake.osModules.home-manager =
    { lib, ... }:
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
              extraGroups = [
                "docker"
                "networkmanager"
                "wheel"
              ];
            };
          }) userNames
        );
      };
    };
}

{
  self,
  inputs,
  ...
}:
let
  # TODO: better way
  users = [ "loris" ];
in
{
  flake.darwinModules.home-manager =
    { ... }:
    {
      imports = [
        inputs.home-manager.darwinModules.home-manager
      ];

      home-manager.useGlobalPkgs = true;
      home-manager.sharedModules = [
        self.homeModules.default
      ];

      system.primaryUser = builtins.head users;

      users.users = builtins.listToAttrs (
        builtins.map (userName: {
          name = userName;
          value = {
            home = "/Users/${userName}";
          };
        }) users
      );

      home-manager.users = builtins.listToAttrs (
        builtins.map (userName: {
          name = userName;
          value = {
            imports = [
              self.homeModules.${userName}
            ];
          };
        }) users
      );
    };
}

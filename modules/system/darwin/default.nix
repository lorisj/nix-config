{
  flake,
  self,
  inputs,
  withSystem,
  ...
}:
let
  # TODO: better way
  users = [ "loris" ];
in
{
  flake.darwinModules.default =
    { ... }:
    {
      imports = [
        inputs.home-manager.darwinModules.home-manager
        {
          # home manager setup:
          home-manager.useGlobalPkgs = true;
          home-manager.sharedModules = [
            self.homeModules.default
          ];

          home-manager.extraSpecialArgs = {
            # TODO: figure out a better way to do this
            inherit inputs;
          };

          # users
          users.users = builtins.listToAttrs (
            builtins.map (userName: {
              name = userName;
              value = {
                home = "/Users/${userName}";
              };
            }) users
          );

          # home manager
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
        }
        self.darwinModules.shared.default
      ]
      ++ [
        self.darwinModules.theme.stylix
        self.darwinModules.test.test
      ];

    };
}

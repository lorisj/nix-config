{
  self,
  flakeModuleHelpers,
  ...
}:
{
  flake.darwinModules.default =
    { ... }:
    {
      imports = [
        self.darwinModules.home-manager
      ]
      ++ flakeModuleHelpers.sortedNestedFlakeModules {
        output = "sharedModules";
        excludedTopLevelNames = [ "default" ];
      }
      ++ flakeModuleHelpers.sortedNestedFlakeModules {
        output = "darwinModules";
        excludedTopLevelNames = [
          "default"
          "home-manager"
        ];
      };
    };
}

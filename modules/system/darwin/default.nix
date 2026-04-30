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
      ]
      ++ flakeModuleHelpers.sortedNestedFlakeModules {
        output = "sharedModules";
        excludedTopLevelNames = [ "default" ];
      }
      ++ flakeModuleHelpers.sortedNestedFlakeModules {
        output = "darwinModules";
        excludedTopLevelNames = [
          "default"
        ];
      };
    };
}

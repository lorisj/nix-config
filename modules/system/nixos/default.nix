{
  flakeModuleHelpers,
  ...
}:
{
  flake.osModules.default =
    { ... }:
    {
      imports = [ ]
      ++ flakeModuleHelpers.sortedNestedFlakeModules {
        output = "osModules";
        excludedTopLevelNames = [
          "default"
          "hardwareConfigurations"
        ];
      }
      ++ flakeModuleHelpers.sortedNestedFlakeModules {
        output = "sharedModules";
        excludedTopLevelNames = [ "default" ];
      };
    };
}

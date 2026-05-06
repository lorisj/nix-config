{
  flakeModuleHelpers,
  ...
}:
{
  flake.nixosModules.default =
    { ... }:
    {
      imports = [ ]
      ++ flakeModuleHelpers.sortedNestedFlakeModules {
        output = "nixosModules";
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

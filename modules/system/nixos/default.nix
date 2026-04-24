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
        excludedTopLevelNames = [ "default" ];
      }
      ++ flakeModuleHelpers.sortedNestedFlakeModules {
        output = "sharedModules";
        excludedTopLevelNames = [ "default" ];
      };
    };
}

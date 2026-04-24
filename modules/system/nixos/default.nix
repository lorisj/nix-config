{
  flake,
  flakeModuleHelpers,
  ...
}:
{
  flake.nixosModules.default =
    { ... }:
    {
      imports = [ ]
      ++ flakeModuleHelpers.sortedNestedFlakeModules {
        output = "sharedModules";
        excludedTopLevelNames = [ "default" ];
      };
    };
}

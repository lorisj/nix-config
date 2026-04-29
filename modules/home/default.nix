{
  flake,
  inputs,
  flakeModuleHelpers,
  ...
}:
{
  flake.homeModules.default =
    { ... }:
    {
      imports = [
        inputs.nix-colors.homeManagerModules.default
      ]
      ++ flakeModuleHelpers.sortedNestedFlakeModules {
        output = "homeModules";
        excludedTopLevelNames = [ "default" ];
      };
      config = {
        home.stateVersion = "24.05";
      };
    };
}

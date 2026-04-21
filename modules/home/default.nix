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
      home.stateVersion = "24.05";
      imports = [
        inputs.nix-colors.homeManagerModules.default
      ] ++ flakeModuleHelpers.sortedFlatFlakeModules {
        output = "homeModules";
        excludedNames = [ "default" "loris" ];
      };
    };
}

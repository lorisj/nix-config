# Composed nixvim config as `self.nixvimModules.default`.
# `packages.nixvim` in flake-outputs.nix inlines the same `imports` list to avoid an evaluation
# cycle while `perSystem.packages` is being resolved for `self`.
{ flakeModuleHelpers, ... }:
{
  flake.nixvimModules.default =
    { ... }:
    {
      imports = flakeModuleHelpers.sortedNestedFlakeModules {
        output = "nixvimModules";
        excludedTopLevelNames = [ "default" ];
      };
    };
}

{ flakeModuleHelpers, ... }:
{
  perSystem =
    { inputs', pkgs, ... }:
    {
      packages.nixvim = inputs'.nixvim.legacyPackages.makeNixvimWithModule {
        inherit pkgs;
        # Inline aggregate avoids a cycle: `self.nixvimModules.default.*` is not available
        # while `perSystem.packages` is still being resolved for `self`.
        module = {
          imports = flakeModuleHelpers.sortedNestedFlakeModules {
            output = "nixvimModules";
            excludedTopLevelNames = [ "default" ];
          };
        };
      };
    };
}

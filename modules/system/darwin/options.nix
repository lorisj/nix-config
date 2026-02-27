{ lib, ... }:
let
  inherit (lib) mkOption types;
  level3 = types.unspecified;
  level2 = types.either level3 (types.lazyAttrsOf level3);
  level1 = types.either level2 (types.lazyAttrsOf level2);
  darwinModulesType = types.lazyAttrsOf level1;
in
{
  options.flake.darwinModules = mkOption {
    type = darwinModulesType;
    default = { };
  };
}

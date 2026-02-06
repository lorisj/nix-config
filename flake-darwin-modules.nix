# Declares flake.darwinModules so multiple modules can define different paths
# (e.g. darwinModules.default, darwinModules.shared.theme.stylix) and they merge.
# See https://flake.parts and flake-parts' modules/nixosModules.nix for the pattern.
{ flake, lib, ... }:
let
  inherit (lib) mkOption types;
  # Allow nested attrsets so darwinModules.default, darwinModules.shared.default,
  # darwinModules.shared.nix.settings, etc. all merge (up to 3 levels).
  level3 = types.unspecified;
  level2 = types.either level3 (types.lazyAttrsOf level3);
  level1 = types.either level2 (types.lazyAttrsOf level2);
  darwinModulesType = types.lazyAttrsOf level1;
in
{
  options = {
    flake.darwinModules = mkOption {
      type = darwinModulesType;
      default = { };
      description = ''
        Darwin modules. Multiple modules can set e.g. flake.darwinModules.default
        and flake.darwinModules.shared.theme.stylix; definitions are merged.
      '';
    };
  };
}

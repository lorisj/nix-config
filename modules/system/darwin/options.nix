{ lib, ... }:
let
  inherit (lib) mkOption types;
  darwinModuleType =
    let
      moduleOrAttrs =
        depth:
        if depth == 0 then
          types.raw
        else
          types.either (types.lazyAttrsOf (moduleOrAttrs (depth - 1))) types.raw;
    in
    moduleOrAttrs 3;
in
{
  options.flake.darwinModules = mkOption {
    type = types.lazyAttrsOf darwinModuleType;
    default = { };
  };
}

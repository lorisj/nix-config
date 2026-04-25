# `flake.{sharedModules,darwinModules,nixvimModules}` share one leaf type: `customFlakeModuleType`.
{ lib, ... }:
let
  inherit (lib) types;

  customFlakeModuleType =
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
  options.flake.sharedModules = lib.mkOption {
    type = types.lazyAttrsOf customFlakeModuleType;
    default = { };
  };

  options.flake.darwinModules = lib.mkOption {
    type = types.lazyAttrsOf customFlakeModuleType;
    default = { };
  };

  options.flake.nixvimModules = lib.mkOption {
    type = types.lazyAttrsOf customFlakeModuleType;
    default = { };
  };
}

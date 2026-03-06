{ lib, ... }:
let
  inherit (lib) mkOption types;
  # Same pattern as darwin/options.nix: nested lazyAttrsOf so multiple modules can set e.g. base.plugins.* and they merge.
  nixvimModuleType =
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
  options.flake.modules.nixvim = mkOption {
    type = types.lazyAttrsOf nixvimModuleType;
    default = { };
  };
}

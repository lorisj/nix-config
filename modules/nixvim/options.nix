{ lib, ... }:
let
  inherit (lib) mkOption types;
  nixvimModuleType = types.lazyAttrsOf ( types.either
      (types.listOf types.anything)
      (types.lazyAttrsOf types.anything)
  );
in
{
  # options.flake.modules.nixvim = mkOption {
  #   type = types.lazyAttrsOf nixvimModuleType;
  #   default = { };
  # };
  options.flake.modules.nixvim = mkOption {
    type = types.lazyAttrsOf types.deferredModule;
    default = { };
  };

}

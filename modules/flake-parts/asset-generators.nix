{ flake-parts-lib, lib, ... }:
flake-parts-lib.mkTransposedPerSystemModule {
  name = "assetGenerators";
  option = lib.mkOption {
    type = lib.types.lazyAttrsOf lib.types.raw;
    default = { };
    description = "Per-system functions that build generated image assets.";
  };
  file = ./asset-generators.nix;
}

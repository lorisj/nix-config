{ lib, ... }:
{
  options.flake.modules.nixvim = lib.mkOption {
    type = lib.types.lazyAttrsOf lib.types.unspecified;
    default = { };
  };
}

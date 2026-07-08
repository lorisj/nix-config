{ lib, self, ... }:
let
  inherit (lib) types;
in
{
  options.flake.assetPaths = lib.mkOption {
    type = types.lazyAttrsOf types.str;
    default = { };
  };

  config.flake.assetPaths = {
    programIcons = "${self.outPath}/.assets/sketchybar-icons";
  };
}

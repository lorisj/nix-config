# Binds `lib` + `self` once so other flake modules can use `flakeModuleHelpers.*` without importing ../../lib or passing `self`.
{ lib, self, ... }:
{
  _module.args.flakeModuleHelpers = import ../lib/flake-modules.nix { inherit lib self; };
}

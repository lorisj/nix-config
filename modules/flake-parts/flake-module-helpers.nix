# Binds `lib` + `self` once so other flake modules can use `flakeModuleHelpers.*` without importing lib paths or passing `self`.
# Declares `flake.sharedModules` so many flake-parts files can set distinct paths (e.g. `sharedModules.theme.stylix`) and merge; see
# `modules/nixosModules.nix` in flake-parts.
{ lib, self, ... }:
{
  options.flake = {
    sharedModules = lib.mkOption {
      type = lib.types.lazyAttrsOf (lib.types.lazyAttrsOf lib.types.deferredModule);
      default = { };
    };
  };

  config._module.args.flakeModuleHelpers = {
    # Direct children of `self.<output>` are modules; use `excludedNames` for aggregators and per-user modules.
    sortedFlatFlakeModules =
      { output, excludedNames }:
      let
        names = lib.sort lib.lessThan (
          lib.attrNames (
            lib.filterAttrs (name: _: ! builtins.elem name excludedNames) self.${output}
          )
        );
      in
      map (name: self.${output}.${name}) names;

    # takes output="darwinModules". Then looks for every "darwinModules.<something>" and collects them into a flattened list.
    sortedNestedFlakeModules =
      { output, excludedTopLevelNames }:
      let
        o = self.${output};
        collect =
          value:
          if lib.isFunction value then
            [ value ]
          else if lib.isAttrs value && !(value ? outPath) then
            if (value ? imports || value ? options || value ? config) then
              [ value ]
            else
              lib.concatMap (n: collect value.${n}) (lib.sort lib.lessThan (lib.attrNames value))
          else
            [ ];
        topNames = lib.sort lib.lessThan (
          lib.filter (name: ! builtins.elem name excludedTopLevelNames) (lib.attrNames o)
        );
      in
      lib.concatMap (n: collect o.${n}) topNames;
  };
}

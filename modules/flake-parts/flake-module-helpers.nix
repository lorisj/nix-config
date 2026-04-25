# Binds `lib` + `self` once so other flake modules can use `flakeModuleHelpers.*` without importing lib paths or passing `self`.
# `flake.{sharedModules,darwinModules,nixvimModules,homeModules}` are declared in `module-system.nix`.
{ lib, self, ... }:
{
  config._module.args.flakeModuleHelpers = {
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

{ lib, self }:
{
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

  # Mix of leaf modules and nested namespaces; skips listed top-level names, recurses for the rest.
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
}

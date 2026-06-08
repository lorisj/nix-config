{ ... }:
{
  flake.nixvimModules.options =
    { lib, ... }:
    {
      options.loris.nixvim.navigationPrefix = lib.mkOption {
        type = lib.types.str;
        default = "q";
        example = "z";
        description = "Prefix key for custom navigation and tool mappings.";
      };
    };
}

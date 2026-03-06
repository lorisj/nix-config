{
  config,
  inputs,
  lib,
  ...
}:
let
  # Captured from flake config (outer scope); inner scope only has home-manager config.
  nixvimBase = config.flake.modules.nixvim.base;
in
{
  flake.homeModules.nixvim =
    { config, pkgs, ... }:
    let
      # base16 colorscheme expects #color; nix-colors palette has hex without #
      colors =
        with config.colorScheme.palette;
        lib.mapAttrs (_name: value: "#" + value) {
          inherit
            base00
            base01
            base02
            base03
            base04
            base05
            base06
            base07
            base08
            base09
            base0A
            base0B
            base0C
            base0D
            base0E
            base0F
            ;
        };

      paletteModule = {
        colorschemes.base16 = {
          enable = true;
          colorscheme = colors;
        };
      };

      # makeNixvimWithModule expects a single module, not a "merge" value.
      nixvimModule =
        base: palette:
        { ... }:
        { config = lib.mkMerge [ base palette ]; };

      nixvim = inputs.nixvim.legacyPackages.${pkgs.stdenv.hostPlatform.system}.makeNixvimWithModule {
        inherit pkgs;
        module = nixvimModule nixvimBase paletteModule;
      };
    in
    {
      home.packages = [ nixvim ];
      home.sessionVariables.EDITOR = lib.getExe nixvim;
    };
}

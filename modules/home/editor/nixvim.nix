{
  inputs,
  lib,
  self,
  ...
}:
{
  flake.homeModules.editor.nixvim =
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

      nixvim = inputs.nixvim.legacyPackages.${pkgs.stdenv.hostPlatform.system}.makeNixvimWithModule {
        inherit pkgs;
        module = {
          imports = [
            self.nixvimModules.default
            paletteModule
          ];
        };
      };
    in
    let
      nixvimExe = lib.getExe nixvim;
    in
    {
      config = {
        # NOTE: Nerd Font from home.packages is installed where macOS/GUI apps see it (e.g. ~/Library/Fonts/HomeManager).
        fonts.fontconfig.enable = true;
        home.packages = [
          nixvim
          pkgs.nerd-fonts.fira-code
          pkgs.nixfmt

        ];
        home.sessionVariables.EDITOR = nixvimExe;
        home.shellAliases = {
          vi = nixvimExe;
          vim = nixvimExe;
        };
      };
    };
}

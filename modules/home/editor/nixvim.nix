{ config, inputs, lib, ... }:
{
  flake.homeModules.nixvim =
    { pkgs, ... }:
    let
      nixvim = inputs.nixvim.legacyPackages.${pkgs.stdenv.hostPlatform.system}.makeNixvimWithModule {
        inherit pkgs;
        module = config.flake.modules.nixvim.base;
      };
    in
    {
      home.packages = [ nixvim ];
      home.sessionVariables.EDITOR = lib.getExe nixvim;
    };
}

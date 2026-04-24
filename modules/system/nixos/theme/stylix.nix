{ inputs, ... }:
{
    flake.nixosModules.display.stylix = {config, pkgs, lib, ... } : {
        imports = [ inputs.stylix.nixosModules.stylix ];
    };
}
{ inputs, ... }:
{
    flake.osModules.display.stylix = {config, pkgs, lib, ... } : {
        imports = [ inputs.stylix.nixosModules.stylix ];
    };
}
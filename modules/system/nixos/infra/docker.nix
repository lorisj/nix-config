
{ ... }:
{
    flake.nixosModules.infra.docker = {config, pkgs, lib, ... } : {
        config = {
            virtualisation.docker = {
                enable = true;
            };
        };
    };
}
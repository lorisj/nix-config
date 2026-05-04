{ ... }:
{
    flake.nixosModules.hardware.nvidia = { config, pkgs, lib, ... }: {
        options = {
            os.hardware.nvidia.enabled = lib.mkEnableOption "nvidia";
        };
        config = lib.mkIf config.os.hardware.nvidia.enabled {
            hardware = {
                graphics.enable = true;
                nvidia.modesetting.enable = true;
            };
        };
    };
}
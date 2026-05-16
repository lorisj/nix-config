{ ... }:
{
  flake.osModules.hardware.nvidia =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {
      options = {
        os.hardware.nvidia.enabled = lib.mkEnableOption "nvidia";
      };
      config = lib.mkIf config.os.hardware.nvidia.enabled {
        hardware = {
          graphics.enable = true;
          nvidia.modesetting.enable = true;
          nvidia.open = true;
        };
        services.xserver.videoDrivers = [ "nvidia" ];
        nixpkgs.config.cudaSupport = true;
      };
    };
}

{ ... }:
{
  flake.osModules.boot.loader =
    { config, lib, ... }:
    {
      options = {
        os.boot.loader.enabled = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Enable the default physical-machine bootloader.";
        };
      };

      config = lib.mkIf config.os.boot.loader.enabled {
        boot.loader = {
          systemd-boot.enable = true;
          efi.canTouchEfiVariables = true;
        };
      };
    };
}

{ ... }:
{
  flake.osModules.hardware.bluetooth =
    { config, lib, ... }:
    {
      options = {
        os.hardware.bluetooth.enabled = lib.mkEnableOption "Bluetooth";
      };

      config = lib.mkIf config.os.hardware.bluetooth.enabled {
        hardware.bluetooth = {
          enable = true;
          powerOnBoot = true;
        };
      };
    };
}

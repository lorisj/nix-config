{ ... }:
{
  flake.osModules.services.printing =
    { config, lib, ... }:
    {
      options = {
        os.services.printing.enabled = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Enable CUPS printing support.";
        };
      };

      config = lib.mkIf config.os.services.printing.enabled {
        services.printing.enable = true;
      };
    };
}

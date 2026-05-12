{ ... }:
{
  flake.osModules.networking.firewall =
    { config, lib, ... }:
    {
      options = {
        os.networking.firewall.enabled = lib.mkEnableOption "firewall";
      };
      config = lib.mkIf config.os.networking.firewall.enabled {
        networking.firewall = {
          enable = true;
          allowedTCPPorts = [ 3001 ];
          allowedUDPPorts = [ 3001 ];
        };
      };
    };
}

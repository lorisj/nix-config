{ ... }:
{
  flake.osModules.network.firewall =
    { config, lib, ... }:
    {
      options = {
        os.network.firewall.enabled = lib.mkEnableOption "firewall";
      };
      config = lib.mkIf config.os.network.firewall.enabled {
        networking.firewall = {
          enable = true;
          allowedTCPPorts = [ 3001 ];
          allowedUDPPorts = [ 3001 ];
        };
      };
    };
}

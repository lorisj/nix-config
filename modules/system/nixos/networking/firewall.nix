{ ... }:
{
  flake.osModules.network.firewall =
    { config, lib, ... }:
    {
      options = {
        os.newtwork.firewall.enabled = lib.mkEnableOption "firewall";
      };
      config = lib.mkIf config.os.nework.firewall.enabled {
        networking.firewall = {
          enable = true;
          allowedTCPPorts = [ 3001 ];
          allowedUDPPorts = [ 3001 ];
        };
      };
    };
}

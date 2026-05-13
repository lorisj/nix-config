{ ... }:
{
  flake.osModules.networking.tailscale =
    { config, lib, ... }:
    {
      options = {
        os.networking.tailscale.enabled = lib.mkEnableOption "tailscale";
        os.networking.tailscale.allowedTCPPorts = lib.mkOption {
          type = lib.types.listOf lib.types.port;
          default = [ ];
          description = "TCP ports to allow through the firewall on the tailscale0 interface.";
        };
      };
      config = lib.mkIf config.os.networking.tailscale.enabled {
        services.tailscale = {
          enable = true;
          authKeyFile = "/etc/tailscale/authKey";
        };

        networking.firewall = {
          interfaces.tailscale0.allowedTCPPorts = config.os.networking.tailscale.allowedTCPPorts;
        };
      };
    };
}

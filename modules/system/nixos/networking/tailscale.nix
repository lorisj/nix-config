{ ... }:
{
  flake.osModules.networking.tailscale =
    { config, lib, ... }:
    {
      options = {
        os.networking.tailscale.enabled = lib.mkEnableOption "tailscale";
      };
      config = lib.mkIf config.os.networking.tailscale.enabled {
        services.tailscale.enable = true;
        networking.firewall.trustedInterfaces = [ "tailscale0" ];
      };
    };
}

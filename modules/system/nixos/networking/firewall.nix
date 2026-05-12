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
          extraInputRules = ''
            ip saddr 192.168.50.74 tcp dport 3001 accept
            ip saddr != 192.168.50.74 tcp dport 3001 drop
          '';
        };
      };
    };
}

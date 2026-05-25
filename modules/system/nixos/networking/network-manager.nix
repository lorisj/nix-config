{
  flake.osModules.network.network-manager =
    { config, lib, ... }:
    let
      cfg = config.os.networking.wpaSupplicant;
    in
    {
      options = {
        os.networking.wpaSupplicant.enabled = lib.mkEnableOption "wpa_supplicant";
      };

      config = {
        networking.networkmanager.enable = true;
        networking.wireless.enable = lib.mkForce cfg.enabled;
      };
    };
}

{
  self,
  inputs,
  ...
}:
{
  imports = [ ./hardware-configuration.nix ];
  flake.nixosConfigurations.server = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.osModules.hardwareConfigurations.server
      self.osModules.default
      {
        system.stateVersion = "25.11";

        os.display.hyprland.enabled = false;
        # os.display.hyprland.displayScaling = 2;
        os.networking.firewall.enabled = true;
        os.networking.wpaSupplicant.enabled = true;
        os.networking.tailscale.enabled = true;
        os.networking.tailscale.allowedTCPPorts = [
          3001
          22
        ];
        networking.hostName = "nixos-server";
        os.hardware.nvidia.enabled = true;
        os.networking.ssh.enabled = true;
      }
    ];
  };
}

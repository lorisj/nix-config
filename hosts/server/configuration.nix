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
        time.timeZone = "America/Los_Angeles";
        i18n.defaultLocale = "en_US.UTF-8";

        i18n.extraLocaleSettings = {
          LC_ADDRESS = "en_US.UTF-8";
          LC_IDENTIFICATION = "en_US.UTF-8";
          LC_MEASUREMENT = "en_US.UTF-8";
          LC_MONETARY = "en_US.UTF-8";
          LC_NAME = "en_US.UTF-8";
          LC_NUMERIC = "en_US.UTF-8";
          LC_PAPER = "en_US.UTF-8";
          LC_TELEPHONE = "en_US.UTF-8";
          LC_TIME = "en_US.UTF-8";
        };

        boot.loader.systemd-boot.enable = true;
        boot.loader.efi.canTouchEfiVariables = true;
        services.printing.enable = true;

        system.stateVersion = "25.11";

        os.display.hyprland.enabled = false;
        # os.display.hyprland.displayScaling = 2;
        os.networking.firewall.enabled = true;
        os.networking.tailscale.enabled = true;
        os.networking.tailscale.allowedTCPPorts = [
          3001
          22
        ];
        networking.hostName = "nixos-server";
        os.hardware.nvidia.enabled = true;

      }
    ];
  };
}

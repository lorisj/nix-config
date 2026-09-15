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
        config = {
          system.stateVersion = "25.11";
          os.users.loris.isAdmin = true;
          os.users.steam.isAdmin = false;
          specialisation.game.configuration = {
            config = {
              os.display.steam = {
                enabled = true;
                width = 3840;
                height = 2160;
              };
              os.games.minecraft = {
                enabled = true;
                port = 32151;
              };
              services.minecraft-server.serverProperties = {
                # Settings from the SteamPunk v19 server pack.
                allow-flight = true;
                enable-command-block = true;
                difficulty = "normal";
                max-players = 10;
                max-tick-time = 120000;
                motd = "A SteamPunk Server";
              };
            };
          };

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
          os.hardware.bluetooth.enabled = true;
          os.hardware.nvidia.enabled = true;
          os.networking.ssh.enabled = true;
        };
      }
    ];
  };
}

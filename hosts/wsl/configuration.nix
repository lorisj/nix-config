{
  self,
  inputs,
  ...
}:
{
  flake.nixosConfigurations.wsl = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      inputs.nixos-wsl.nixosModules.default
      self.osModules.default
      ./nvidia.nix
      {
        wsl = {
          enable = true;
          defaultUser = "loris";
        };

        networking.hostName = "nixos-wsl";
        system.stateVersion = "25.11";
        os.hardware.nvidia.enabled = true;
        os.networking.tailscale.enabled = true;
        os.networking.tailscale.allowedTCPPorts = [
          8081
          3001
          22
        ];
      }
    ];
  };
}

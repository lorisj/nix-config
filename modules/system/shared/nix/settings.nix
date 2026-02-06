{ flake, ... }:
let
  sharedModule =
    { ... }:
    {
      nix.settings.substituters = [
        "https://cache.nixos.org"
        "https://cuda-maintainers.cachix.org"
      ];

      nix.settings.trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
      ];

      nix.settings.experimental-features = [
        "nix-command"
        "flakes"
      ];

      # Allow unfree packages
      nixpkgs.config.allowUnfree = true;
    };
in
{
  flake.nixosModules.shared.nix.settings = sharedModule;
  flake.darwinModules.shared.nix.settings = sharedModule;
}

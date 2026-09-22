{ ... }:
{
  flake.sharedModules.nix.settings =
    { ... }:
    {
      config = {
        nix.settings.substituters = [
          "https://cache.nixos.org"
          "https://nix-community.cachix.org"
          "https://cache.nixos-cuda.org"
        ];

        nix.settings.trusted-public-keys = [
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M="
        ];

        nix.settings.experimental-features = [
          "nix-command"
          "flakes"
        ];

        nix.settings.fallback = true;

        # Allow unfree packages
        nixpkgs.config.allowUnfree = true;
      };
    };
}

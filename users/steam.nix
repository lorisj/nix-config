{ inputs, self, ... }:
{
  flake.userConfig.steam = {
    nixos.extraGroups = [
      "audio"
      "video"
      "input"
      "gamemode"
    ];
    # No keys of its own; Loris administers this account over SSH.
    nixos.sshKeys = self.userConfig.loris.nixos.sshKeys;
    module =
      { ... }:
      {
        config = {
          gitConfig = {
            userName = "steam";
            userEmail = "steam@localhost";
          };
          colorScheme = inputs.nix-colors.colorSchemes.circus;
          wallpaperPath = self.assets.images.roundHill;
        };
      };
  };
}

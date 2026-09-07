{ inputs, self, ... }:
{
  flake.userConfig.steam = {
    nixos.extraGroups = [
      "audio"
      "video"
      "input"
      "gamemode"
    ];
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

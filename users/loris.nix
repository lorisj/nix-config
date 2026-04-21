{ inputs, flake, ... }:
{

  flake.homeModules.loris =
    { ... }:
    {
      gitConfig = {
        userName = "lorisj";
        userEmail = "lorisjautakas@gmail.com";
      };

      colorScheme = inputs.nix-colors.colorSchemes.circus;
      #colorScheme = inputs.nix-colors.colorSchemes.danqing;
      #colorScheme = inputs.nix-colors.colorSchemes.flat;
      #colorScheme = inputs.nix-colors.colorSchemes.catppuccin-mocha;
      #colorScheme = inputs.nix-colors.colorSchemes.atelier-sulphurpool;
      #colorScheme = inputs.nix-colors.colorSchemes.chalk;
      wallpaperPath = ../.assets/round-hill.jpg;
    };
}

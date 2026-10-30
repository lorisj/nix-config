{ inputs, self, ... }:
{
  flake.userConfig.dmpribak = {
    nixos.sshKeys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM0Rpqm2U+iScOcfWWIQk1a3m7uIff2MFxLPFB2BF8yg"
    ];
    module =
      { ... }:
      {
        config = {
          gitConfig = {
            userName = "Dillan Pribak";
            userEmail = "dmpribak@gmail.com";
          };
          colorScheme = inputs.nix-colors.colorSchemes.circus;
          wallpaperPath = self.assets.images.roundHill;
        };
      };
  };
}

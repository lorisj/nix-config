{ inputs, self, ... }:
{
  flake.userConfig.loris = {
    nixos.sshKeys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICeZI2pBSxv1fs6V8hAe5DDyHSUT4UCcQZTXK9sLPxwt"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOgykMePA2aCBXm2uktQSnI4p4f0++eWZ5hYF80vtrMo"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFZU98KS18bZSgmD7xsKozlldpneJW8zlgzi5HvxWog0"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDHszkI7lSEaP7U/9Q6CwKKbaeFLD9OUEy3MbtW1XsOX"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL2RTDsJaDSTq7YFlz21IgLUUcJzuQejfkNjDAcp7YWE"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMrSmI3BrKrOR9r402C+ka+91lC5bHu5UuJaLZGR3UoZ"
    ];
    module =
      { ... }:
      {
        gitConfig = {
          userName = "lorisj";
          userEmail = "lorisjautakas@gmail.com";
        };
        editor.nixvim.aiAssistant = "codex";
        # sorted in order of preference:
        colorScheme = inputs.nix-colors.colorSchemes.circus;
        #colorScheme = inputs.nix-colors.colorSchemes.danqing;
        #colorScheme = inputs.nix-colors.colorSchemes.flat;
        #colorScheme = inputs.nix-colors.colorSchemes.catppuccin-mocha;
        #colorScheme = inputs.nix-colors.colorSchemes.atelier-sulphurpool;
        #colorScheme = inputs.nix-colors.colorSchemes.chalk;
        wallpaperPath = self.assets.images.roundHill;
      };
  };
}

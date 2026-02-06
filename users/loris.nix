{ inputs, flake, ... }:
{

  flake.homeModules.loris =
    { ... }:
    {
      gitConfig = {
        userName = "lorisj";
        userEmail = "lorisjautakas@gmail.com";
      };
      colorScheme = inputs.nix-colors.colorSchemes.danqing;
      wallpaperPath = ../.assets/round-hill.jpg;
    };
  # home.web.firefoxProfile = {
  #    "browser.startup.homepage" = "https://nixos.org";
  # bookmarks = [
  # https://gitlab.com/Zaney/zaneyos/-/tree/main/cheatsheets?ref_type=heads
  # https://dt.iki.fi/base16-previews
  # https://github.com/GaetanLepage/nix-config/tree/master/modules
  #];
  #extraGroups = [ "docker" ];
  #};
}

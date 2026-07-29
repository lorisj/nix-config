{ self, ... }:
{
  flake.sharedModules.theme.stylix =
    { pkgs, ... }:
    {
      config = {
        stylix.enable = true;
        stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-hard.yaml";
        stylix.image = self.assets.images.vanSickle;
      };
    };
}

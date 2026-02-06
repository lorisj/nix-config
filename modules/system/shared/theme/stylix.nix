{ inputs, flake, ... }:
let
  sharedModule =
    { pkgs, ... }:
    {
      stylix.enable = true;
      stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-hard.yaml";
      stylix.image = ../../../../.assets/van-sickle.jpg;
    };
in
{
  flake.darwinModules.shared.theme.stylix = sharedModule;
  flake.nixosModules.shared.theme.stylix = sharedModule;
}

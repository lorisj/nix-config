{ inputs, ... }:
{
  flake.homeModules.starship =
    { pkgs, lib, config, ... }:
    let
  colors = config.colorScheme.palette; # colors.base00, ...
in
{
  programs.starship = {
    enable = true;
    # TODO: make replace-by-set depend on lib instead of curried funciton
    settings = builtins.fromTOML (
      inputs.nix-helpers.lib.replace-by-set { inherit lib; } colors (
        builtins.readFile ./starship-config.toml
      )
    ); # settings is of type TOML value
  };

};
}


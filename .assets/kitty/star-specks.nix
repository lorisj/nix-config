{
  inputs,
  lib,
  pkgs,
  palette,
}:
let
  template = builtins.readFile ./star-specks.py;
  script = inputs.nix-helpers.lib.replace-by-set { inherit lib; } palette template;
  generator = pkgs.writeText "kitty-star-specks.py" script;
  python = pkgs.python3.withPackages (pythonPackages: [ pythonPackages.pillow ]);
  densityMask = pkgs.fetchurl {
    url = "https://www.transparenttextures.com/patterns/subtle-white-feathers.png";
    hash = "sha256-22Hrcb+0CAZQPKvFRHry1vYfcuMwS+ePlpWt3JU6l1o=";
  };
in
pkgs.runCommand "kitty-star-specks" { nativeBuildInputs = [ python ]; } ''
  mkdir -p "$out"
  python ${generator} ${densityMask} "$out/wall-pattern.png"
''

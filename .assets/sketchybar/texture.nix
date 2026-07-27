{
  pkgs,
  source,
}:
let
  python = pkgs.python3.withPackages (pythonPackages: [ pythonPackages.pillow ]);
in
pkgs.runCommand "sketchybar-texture" { nativeBuildInputs = [ python ]; } ''
  mkdir -p "$out"
  python ${./texture.py} ${source} "$out/texture.png"
''

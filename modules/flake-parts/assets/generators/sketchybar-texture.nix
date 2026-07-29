{ self, ... }:
{
  perSystem =
    { pkgs, ... }:
    {
      assetGenerators.sketchybarTexture =
        { source }:
        let
          python = pkgs.python3.withPackages (pythonPackages: [ pythonPackages.pillow ]);
        in
        pkgs.runCommand "sketchybar-texture" { nativeBuildInputs = [ python ]; } ''
          mkdir -p "$out"
          python ${self.assets.sources.sketchybarTexture} ${source} "$out/texture.png"
        '';
    };
}

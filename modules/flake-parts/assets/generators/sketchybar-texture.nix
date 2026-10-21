{ self, ... }:
{
  perSystem =
    { pkgs, ... }:
    {
      assetGenerators.sketchybarTexture =
        { source, frameSource }:
        let
          python = pkgs.python3.withPackages (pythonPackages: [ pythonPackages.pillow ]);
        in
        pkgs.runCommand "sketchybar-texture" { nativeBuildInputs = [ python ]; } ''
          mkdir -p "$out/frames"
          python ${self.assets.sources.sketchybarTexture} ${source} "$out/texture.png"

          for frame in ${frameSource}/frame-*.png; do
            output="$out/frames/$(basename "$frame")"
            python ${self.assets.sources.sketchybarTexture} "$frame" "$output"
          done
        '';
    };
}

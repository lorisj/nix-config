{ self, ... }:
let
  version = "0.130.0";
in
{
  perSystem =
    { pkgs, ... }:
    let
      src = pkgs.fetchFromGitHub {
        owner = "openai";
        repo = "codex";
        tag = "rust-v${version}";
        hash = "sha256-YeUeYbzUMUx0lhIKdtPa8vUYK2Cj1hmbLb68Y80r71o=";
      };
      sourceRoot = "source/codex-rs";
    in
    {
      packages.codex = pkgs.codex.overrideAttrs {
        inherit version src sourceRoot;
        cargoDeps = pkgs.rustPlatform.fetchCargoVendor {
          inherit src sourceRoot;
          hash = "sha256-cpkj7H/jkKGbfJ92Ty9peqfxibFw2aWWG64tmgeG+2o=";
        };
      };
    };

  flake.homeModules.editor.codex =
    { pkgs, ... }:
    {
      config = {
        home.packages = [ self.packages.${pkgs.stdenv.hostPlatform.system}.codex ];
      };
    };
}

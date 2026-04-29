{ self, ... }:
{
  perSystem =
    { pkgs, ... }:
    {
      packages.slackatui = pkgs.rustPlatform.buildRustPackage rec {
        pname = "slackatui";
        version = "0.1.0-unstable-2026-04-21";

        src = pkgs.fetchFromGitHub {
          owner = "MasonLiebe";
          repo = "slackatui";
          rev = "a789260f67495039ccaef5937f7fd316a4f91df0";
          hash = "sha256-9C79ntQTbuMGY6cz34DbdYap5MYQJmyVbPSGkOgqIgk=";
        };

        cargoHash = "sha256-oW6DAvS+HZJYn2vfsJ133zOLNlMC9LPPOmLy8GOqMV4=";

        nativeBuildInputs = pkgs.lib.optionals pkgs.stdenv.isLinux [
          pkgs.pkg-config
        ];
        buildInputs = pkgs.lib.optionals pkgs.stdenv.isLinux [ pkgs.openssl ];

        meta = with pkgs.lib; {
          description = "Slack client for the terminal (ratatui)";
          homepage = "https://github.com/MasonLiebe/slackatui";
          license = licenses.mit;
          mainProgram = "slackatui";
        };
      };
    };

  flake.homeModules.devops.slackatui =
    { pkgs, ... }:
    {
      config = {
        home.packages = [ self.packages.${pkgs.stdenv.hostPlatform.system}.slackatui ];
      };
    };
}

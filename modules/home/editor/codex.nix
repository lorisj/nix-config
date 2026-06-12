{
  flake.homeModules.editor.codex =
    { lib, pkgs, ... }:
    let
      codexConfigFile = ''
        [tui]
        vim_mode_default = true
      '';
    in
    {
      config = {
        home.packages = [ pkgs.codex ];
        home.activation.codexConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] (
          lib.concatStringsSep "\n" [
            ''config_file="$HOME/.codex/config.toml"''
            ''mkdir -p "$HOME/.codex"''
            ""
            ''if [ -L "$config_file" ]; then''
            ''rm "$config_file"''
            "fi"
            ""
            ''if [ ! -e "$config_file" ]; then''
            ''cat ${pkgs.writeText "codex-config.toml" codexConfigFile} > "$config_file"''
            "fi"
          ]
        );
      };
    };
}

{
  flake.homeModules.editor.codex =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      codexConfigFile = ''
        [tui]
        vim_mode_default = true
      '';
      # CLI overrides also apply when a project selects its own CODEX_HOME.
      playwrightArgs = [
        "--config"
        "mcp_servers.playwright.command=${builtins.toJSON (lib.getExe pkgs.playwright-mcp)}"
        "--config"
        "mcp_servers.playwright.env.PLAYWRIGHT_MCP_USER_DATA_DIR=${builtins.toJSON "${config.xdg.dataHome}/codex/playwright"}"
      ];
      codexWithPlaywright = pkgs.symlinkJoin {
        name = "codex-with-playwright";
        paths = [ pkgs.codex ];
        nativeBuildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram "$out/bin/codex" \
            --add-flags ${lib.escapeShellArg (lib.escapeShellArgs playwrightArgs)}
        '';
        meta = pkgs.codex.meta;
      };
    in
    {
      config = {
        home.packages = [
          codexWithPlaywright
          pkgs.playwright-mcp
        ];
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

{
  flake.homeModules.editor.codex =
    { pkgs, ... }:
    {
      config = {
        home.packages = [ pkgs.codex ];
        home.file.".codex/config.toml".text = ''
          [tui]
          vim_mode_default = true
        '';
      };
    };
}

{ flake, pkgs, ... }:
{
  flake.homeModules.lazygit =
    { pkgs, ... }:
    {
      programs.lazygit = {
        enable = true;
        settings = {
          # neovim for file edit from lazygit
          os.editPreset = "nvim-remote";

          # diff syntax highlighting
          git.pagers = [
            { pager = "delta --dark --paging=never"; }
          ];
        };
      };

      home.packages = [ pkgs.delta ];
    };
}

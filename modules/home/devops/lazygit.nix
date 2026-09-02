{ ... }:
{
  flake.homeModules.devops.lazygit =
    { pkgs, ... }:
    {
      config = {
        programs.lazygit = {
          enable = true;
          settings = {
            # neovim for file edit from lazygit
            os.editPreset = "nvim-remote";

            # diff syntax highlighting
            git.diffRenderers = [
              { command = "delta --dark --paging=never"; }
            ];
          };
        };

        home.packages = [ pkgs.delta ];
      };
    };
}

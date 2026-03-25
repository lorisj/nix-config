{ flake, pkgs, ... }:
{
  flake.homeModules.lazygit =
    { pkgs, ... }:
    {
      programs.lazygit = {
        enable = true;
        settings = {
          os.editPreset = "nvim-remote";
          git.pagers = [
            { pager = "delta --dark --paging=never"; }
          ];
        };
      };

      home.packages = [ pkgs.delta ];
    };
}

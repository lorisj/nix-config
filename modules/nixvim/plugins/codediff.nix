{ ... }:
{
  flake.nixvimModules.plugins.codediff = { ... }: {
    config = {
    plugins.gitsigns = {
      enable = true;
      settings = {
        current_line_blame = true;
        diff_opts.algorithm = "histogram";
      };
    };
    plugins.codediff = {
      enable = true;
      settings = {
        diff.layout = "inline";
      };
    };
    keymaps = [
      {
        mode = "n";
        key = "<leader>d";
        action = "<cmd>CodeDiff file HEAD --inline<CR>";
        options = { desc = "inline git diff"; silent = true; };
      }
      {
        mode = "n";
        key = "<leader>D";
        action = "<cmd>CodeDiff file HEAD --side-by-side<CR>";
        options = { desc = "side-by-side git diff"; silent = true; };
      }
    ];
    };
  };
}

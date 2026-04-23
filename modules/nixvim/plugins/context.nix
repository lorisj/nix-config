{ ... }:
{
  flake.modules.nixvim.base = {
    plugins.treesitter-context.enable = true;
    keymaps = [
      {
        mode = "n";
        key = "<leader>tc";
        action = "<cmd>TSContext toggle<cr>";
        options.desc = "Toggle treesitter context";
        options.silent = true;
      }
    ];
  };
}

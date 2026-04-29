{ ... }:
{
  flake.nixvimModules.plugins.barbar = { ... }: {
    config = {
      plugins.barbar = {
        enable = true;
        keymaps = {
          next.key = "<leader>k";
          previous.key = "<leader>j";
          close = {
            key = "X";
            action = "<Cmd>confirm BufferClose<CR>";
          };
        };
      };
    };
  };
}

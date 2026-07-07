{ ... }:
{
  flake.nixvimModules.plugins.barbar = { ... }: {
    config = {
      plugins.barbar = {
        enable = true;
        keymaps = {
          next.key = "K";
          previous.key = "J";
          close = {
            key = "X";
            action = "<Cmd>confirm BufferClose<CR>";
          };
        };
      };
    };
  };
}

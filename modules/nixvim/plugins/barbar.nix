{
  flake.modules.nixvim.base.plugins.barbar = {
    enable = true;
    keymaps = {
      next.key = "<leader>k";
      previous.key = "<leader>j";
      close.key = "<leader>w>";
    };
  };
}

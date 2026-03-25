{
  flake.modules.nixvim.base = {
    plugins.floaterm = {
      enable = true;
      settings = {
        width = 0.8;
        height = 0.8;
        title = "";
      };
    };
    keymaps = [
      {
        mode = "n";
        key = "<M-,>";
        action = "<cmd>FloatermToggle<cr>";
        options.desc = "Toggle floaterm";
      }
      {
        mode = "t";
        key = "<M-,>";
        action = "<cmd>FloatermToggle<cr>";
        options.desc = "Toggle floaterm";
      }
    ];
  };
}

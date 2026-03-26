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
        key = "<tab>t";
        action = "<cmd>FloatermToggle<cr>";
        options.desc = "Toggle terminal";
      }
      {
        mode = "t";
        key = "<tab>t";
        action = "<cmd>FloatermToggle<cr>";
        options.desc = "Toggle terminal";
      }
    ];
  };
}

{

  flake.modules.nixvim.base = {
    keymaps = [
      {
        mode = "n";
        key = "<tab>b";
        action = ":Neotree action=focus reveal toggle<CR>";
        options.silent = true;
        options.desc = "Toggle file browser";
      }
    ];
    plugins.neo-tree = {
      enable = true;
      settings = {
        close_if_last_window = true;
        window = {
          width = 30;
          auto_expand_width = true;
        };
      };

    };
  };

}

{ ... }:
{

  flake.nixvimModules.plugins.neotree = { ... }: {
    keymaps = [
      {
        mode = ["n" "t"];
        key = "<tab>b";
        # if focused close, else focus/open if needed
        action.__raw = ''
          function()
            if vim.bo.filetype == "neo-tree" then
              vim.cmd("Neotree close")
            else
              vim.cmd("Neotree action=focus reveal")
            end
          end
        '';
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

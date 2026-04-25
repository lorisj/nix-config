{ ... }:
{
  flake.nixvimModules.plugins.aerial = { ... }: {
    plugins.aerial = {
      enable = true;
      settings = {
        attach_mode = "global";
        backends = [
          "treesitter"
          "lsp"
          "markdown"
          "man"
        ];
        keymaps = {
          "<CR>" = "actions.jump";
          "j" = "actions.down_and_scroll";
          "k" = "actions.up_and_scroll";
          "?" = "actions.show_help";
        };
      };
    };
    keymaps = [
      {
        mode = ["n" "t"];
        key = "<tab>a";
        # if focused close, else focus/open if needed
        action.__raw = ''
          function()
            if vim.bo.filetype == "aerial" then
              vim.cmd("AerialClose")
            else
              -- always grab symbols from a real code buffer instead of claude code / etc
              if vim.bo.buftype ~= "" then
                vim.cmd("wincmd p")
              end
              vim.cmd("AerialOpen!")
              -- ensure focus lands on the aerial window
              for _, win in ipairs(vim.api.nvim_list_wins()) do
                if vim.api.nvim_buf_get_option(vim.api.nvim_win_get_buf(win), "filetype") == "aerial" then
                  vim.api.nvim_set_current_win(win)
                  break
                end
              end
            end
          end
        '';
        options.silent = true;
        options.desc = "Toggle aerial";
      }
    ];

  };
}

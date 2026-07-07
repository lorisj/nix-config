{ inputs, ... }:
let
  toggleLazyGit = inputs.nixvim.lib.nixvim.mkRaw ''
    function()
      for _, win in ipairs(vim.api.nvim_list_wins()) do
        local buf = vim.api.nvim_win_get_buf(win)
        if vim.bo[buf].filetype == "lazygit" then
          vim.api.nvim_set_current_win(win)
          if vim.bo[buf].buftype == "terminal" then
            vim.cmd("startinsert")
            vim.api.nvim_feedkeys("q", "t", false)
          end
          return
        end
      end
      if vim.fn.mode() == "t" then
        vim.api.nvim_feedkeys(
          vim.api.nvim_replace_termcodes("<C-\\><C-n>", true, false, true),
          "t",
          false
        )
        vim.schedule(function()
          require("lazygit").lazygit()
        end)
      else
        require("lazygit").lazygit()
      end
    end
  '';
in
{
  flake.nixvimModules.plugins.lazygit =
    { config, ... }:
    let
      navigationPrefix = config.loris.nixvim.navigationPrefix;
    in
    {
      config = {
        plugins.lazygit = {
          enable = true;
          settings = {
            floating_window_border_chars = [
              "╭"
              "━"
              "╮"
              "┃"
              "╯"
              "━"
              "╰"
              "┃"
            ];
          };
        };
        keymaps = [
          {
            mode = [
              "n"
              "i"
              "t"
            ];
            key = "${navigationPrefix}g";
            action = toggleLazyGit;
            options.desc = "LazyGit toggle";
          }
        ];
      };
    };
}

{ ... }:
{
  flake.nixvimModules.keymappings = { ... }: {
    config = {
      globals = {
        mapleader = " ";
        maplocalleader = " ";
      };
      keymaps = [
        # Move windows w/ ctrl
        { mode = ["n" "t"]; key = "<tab>h"; action = "<C-\\><C-n><C-w>h"; options = { desc = "move to left window"; silent = true; }; }
        { mode = ["n" "t"]; key = "<tab>j"; action = "<C-\\><C-n><C-w>j"; options = { desc = "move to below window"; silent = true; }; }
        { mode = ["n" "t"]; key = "<tab>k"; action = "<C-\\><C-n><C-w>k"; options = { desc = "move to above window"; silent = true; }; }
        { mode = ["n" "t"]; key = "<tab>l"; action = "<C-\\><C-n><C-w>l"; options = { desc = "move to right window"; silent = true; }; }
        # Focus main buffer (anything that is not neotree, etc.)
        {
          mode = ["n" "t"];
          key = "<tab>m";
          action.__raw = ''
            function()
              for _, win in ipairs(vim.api.nvim_list_wins()) do
                local buf = vim.api.nvim_win_get_buf(win)
                if vim.bo[buf].buftype == "" and vim.bo[buf].filetype ~= "neo-tree" then
                  vim.api.nvim_set_current_win(win)
                  return
                end
              end
            end
          '';
          options = { desc = "Focus main buffer"; silent = true; };
        }
      ];
    };
  };
}

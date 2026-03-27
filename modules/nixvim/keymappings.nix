{
  flake.modules.nixvim.base = {
    globals = {
      mapleader = " ";
      maplocalleader = " ";
    };
    keymaps = [
      # Move windows w/ ctrl
      { mode = ["n" "t"]; key = "<Tab>h"; action = "<C-\\><C-n><C-w>h"; options = { desc = "move to left window"; silent = true; }; }
      { mode = ["n" "t"]; key = "<Tab>j"; action = "<C-\\><C-n><C-w>j"; options = { desc = "move to below window"; silent = true; }; }
      { mode = ["n" "t"]; key = "<Tab>k"; action = "<C-\\><C-n><C-w>k"; options = { desc = "move to above window"; silent = true; }; }
      { mode = ["n" "t"]; key = "<Tab>l"; action = "<C-\\><C-n><C-w>l"; options = { desc = "move to right window"; silent = true; }; }

    ];
  };
}

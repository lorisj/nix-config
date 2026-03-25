{
  flake.modules.nixvim.base = {pkgs,... }:{
    extraPlugins = [
      pkgs.vimPlugins.claudecode-nvim
    ];
    extraConfigLua = ''
      require('claudecode').setup({})
    '';
    keymaps = [
      {
        mode = "n";
        key = "<leader>ac";
        action = "<cmd>ClaudeCode<cr>";
        options.desc = "Toggle Claude";
      }
      {
        mode = "n";
        key = "<leader>af";
        action = "<cmd>ClaudeCodeFocus<cr>";
        options.desc = "Focus Claude";
      }
      {
        mode = "n";
        key = "<leader>ar";
        action = "<cmd>ClaudeCode --resume<cr>";
        options.desc = "Resume Claude";
      }
      {
        mode = "n";
        key = "<leader>aC";
        action = "<cmd>ClaudeCode --continue<cr>";
        options.desc = "Continue Claude";
      }
      {
        mode = "v";
        key = "<leader>as";
        action = "<cmd>ClaudeCodeSend<cr>";
        options.desc = "Send to Claude";
      }
      {
        mode = "n";
        key = "<leader>aa";
        action = "<cmd>ClaudeCodeDiffAccept<cr>";
        options.desc = "Accept diff";
      }
      {
        mode = "n";
        key = "<leader>ad";
        action = "<cmd>ClaudeCodeDiffDeny<cr>";
        options.desc = "Deny diff";
      }
    ];
  };
}

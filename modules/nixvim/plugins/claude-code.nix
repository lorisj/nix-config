{
  flake.modules.nixvim.base =
    { pkgs, ... }:
    {
      extraPlugins = [
        pkgs.vimPlugins.claudecode-nvim
      ];
      extraConfigLua = ''
        require('claudecode').setup({})
      '';
      keymaps = [
        {
          mode = "n";
          key = "<tab>c";
          action = "<cmd>ClaudeCode<cr>";
          options.desc = "Toggle Claude Code";
        }
        {
          mode = "t";
          key = "<tab>c";
          action = "<cmd>ClaudeCode<cr>";
          options.desc = "Toggle Claude Code";
        }
        {
          mode = "n";
          key = "<leader>ccf";
          action = "<cmd>ClaudeCodeFocus<cr>";
          options.desc = "Focus Claude";
        }
        {
          mode = "n";
          key = "<leader>ccr";
          action = "<cmd>ClaudeCode --resume<cr>";
          options.desc = "Resume Claude";
        }
        {
          mode = "n";
          key = "<leader>ccc";
          action = "<cmd>ClaudeCode --continue<cr>";
          options.desc = "Continue Claude";
        }
        {
          mode = "v";
          key = "<leader>ccs";
          action = "<cmd>ClaudeCodeSend<cr>";
          options.desc = "Send to Claude";
        }
        {
          mode = "n";
          key = "<leader>a";
          action = "<cmd>ClaudeCodeDiffAccept<cr>";
          options.desc = "Accept diff";
        }
        {
          mode = "n";
          key = "<leader>r";
          action = "<cmd>ClaudeCodeDiffDeny<cr>";
          options.desc = "Deny diff";
        }
      ];
    };
}

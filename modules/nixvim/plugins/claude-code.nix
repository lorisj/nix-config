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
          mode = "t";
          key = "<tab>c";
          action = "<cmd>ClaudeCode<cr>";
          options.desc = "Toggle Claude Code";
        }
        {
          mode = "v";
          key = "<leader>cs";
          action = "<cmd>ClaudeCodeSend<cr>";
          options.desc = "Send to Claude";
        }
        {
          mode = "n";
          key = "<leader>ca";
          action = "<cmd>ClaudeCodeDiffAccept<cr>";
          options.desc = "Accept diff";
        }
        {
          mode = "n";
          key = "<leader>cr";
          action = "<cmd>ClaudeCodeDiffDeny<cr>";
          options.desc = "Deny diff";
        }
      ];
    };
}

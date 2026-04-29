{ ... }:
{
  flake.nixvimModules.plugins.claude-code =
    { pkgs, ... }:
    {
      extraPlugins = [
        pkgs.vimPlugins.claudecode-nvim
      ];
      extraConfigLua = ''
        require('claudecode').setup({
          terminal = {
            split_width_percentage = 0.5,
          },
        })
      '';
      keymaps = [
        {
          mode = [
            "n"
            "t"
          ];
          key = "<tab>c";
          # if focused close, else focus/open if needed
          action = "<cmd>ClaudeCodeFocus<cr>";
          options.desc = "Toggle Claude Code";
        }
        {
          mode = "v";
          key = "<tab>c";
          action = "<cmd>ClaudeCodeSend<cr>";
          options.desc = "Send to Claude";
        }
        {
          mode = "n";
          key = "<leader>C";
          action = "<cmd>ClaudeCodeAdd %<cr>";
          options.desc = "Add file to Claude Code";
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

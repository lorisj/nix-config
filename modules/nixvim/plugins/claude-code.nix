{ ... }:
{
  flake.nixvimModules.plugins.claude-code =
    {
      aiAssistant ? "claude-code",
      config,
      lib,
      pkgs,
      ...
    }:
    let
      navigationPrefix = config.loris.nixvim.navigationPrefix;
    in
    {
      config = lib.mkIf (aiAssistant == "claude-code") {
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
              "i"
              "t"
            ];
            key = "${navigationPrefix}c";
            # if focused close, else focus/open if needed
            action = "<cmd>ClaudeCodeFocus<cr>";
            options.desc = "Toggle Claude Code";
          }
          {
            mode = "v";
            key = "${navigationPrefix}c";
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
    };
}

{
  flake.modules.nixvim.base = {
    plugins.claude-code = {
      enable = true;
    };
    keymaps = [
      {
        mode = "n";
        key = "<leader>cc";
        action = ":ClaudeCode<CR>";
        options.desc = "Claude Code";
      }
    ];
  };
}

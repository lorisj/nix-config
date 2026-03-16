{ ... }:
{
  flake.modules.nixvim.base = {
    plugins = {
      codecompanion = {
        enable = true;
        settings = {
          adapters = {
            acp = {
              claude_code.__raw = ''
                function()
                  return require("codecompanion.adapters").extend("claude_code", {
                    env = {
                      ANTHROPIC_API_KEY = "my-api-key",
                    },
                  })
                end
              '';
            };
          };
          strategies = {
            chat = {
              adapter = "claude_code";
            };
            inline = {
              adapter = "claude_code";
            };
            cmd = {
              adapter = "claude_code";
            };
          };
        };
      };
    };
    keymaps = [
      {
        mode = "n";
        key = "<leader>c";
        action = ":CodeCompanionActions<CR>";
        options.desc = "CodeCompanion actions";
      }
    ];
  };
}

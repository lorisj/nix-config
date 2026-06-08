{ ... }:
{
  flake.nixvimModules.plugins.trouble =
    { config, ... }:
    let
      navigationPrefix = config.loris.nixvim.navigationPrefix;
    in
    {
      config = {
        plugins.trouble = {
          enable = true;
          settings = {
            auto_preview = true;
            focus = true;
            keys = {
              j = "next";
              k = "prev";
              "<cr>" = "jump_close";
            };
          };
        };
        keymaps = [
          {
            mode = [
              "n"
              "i"
              "t"
            ];
            key = "${navigationPrefix}d";
            # if focused close, else focus/open if needed
            action.__raw = ''
              function()
                if vim.bo.filetype == "trouble" then
                  require("trouble").close()
                elseif require("trouble").is_open() then
                  require("trouble").focus()
                else
                  vim.cmd("Trouble diagnostics")
                end
              end
            '';
            options = {
              desc = "toggle trouble diagnostics";
              silent = true;
            };
          }
          {
            mode = "n";
            key = "gd";
            action = "<cmd>Trouble lsp_definitions toggle<cr>";
            options = {
              desc = "goto definition (trouble)";
              silent = true;
            };
          }
          {
            mode = "n";
            key = "gr";
            action = "<cmd>Trouble lsp_references toggle<cr>";
            options = {
              desc = "goto references (trouble)";
              silent = true;
            };
          }
        ];
      };
    };
}

{ ... }:
{
  flake.nixvimModules.plugins.noice = { ... }: {
    config = {
      plugins = {
        notify.enable = true;

        noice = {
          enable = true;
          settings = {
            cmdline = {
              enabled = true;
              format = {
                search_down = {
                  kind = "search";
                  pattern = "^/";
                  icon = "";
                  lang = "regex";
                };
                search_up = {
                  kind = "search";
                  pattern = "^%?";
                  icon = "";
                  lang = "regex";
                };
              };
            };
            popupmenu = {
              enabled = true;
              backend = "nui";
            };
            views.cmdline_popup.position = {
              row = "90%";
              col = "50%";
            };
            lsp.override = {
              "vim.lsp.util.convert_input_to_markdown_lines" = true;
              "vim.lsp.util.stylize_markdown" = true;
              "cmp.entry.get_documentation" = true;
            };
            presets = {
              bottom_search = false;
              command_palette = true;
              long_message_to_split = true;
              inc_rename = false;
            };
          };
        };
      };
    };
  };
}

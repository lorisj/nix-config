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
            };
            popupmenu = {
              enabled = true;
              backend = "nui";
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

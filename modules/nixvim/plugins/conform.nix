{ ... }:
{
  flake.nixvimModules.plugins.conform = { ... }: {
    config = {
    plugins.conform-nvim = {
      enable = true;

      settings = {
        notify_on_error = true;

        formatters_by_ft = {
          javascript = [ "biome" ];
          typescript = [ "biome" ];
          javascriptreact = [ "biome" ];
          typescriptreact = [ "biome" ];
          json = [ "biome" ];
          jsonc = [ "biome" ];
        };

        format_on_save = ''
          function(bufnr)
              local disable_filetypes = { c = true, cpp = true }
              if disable_filetypes[vim.bo[bufnr].filetype] then 
                  return nil
              else
                  return {
                      timeout_ms = 5000,
                      lsp_format = "fallback",
                  }
              end
          end
        '';
      };
    };
    keymaps = [
      {
        mode = "n";
        key = "<leader>F";
        action.__raw = ''
          function()
              require('conform').format { async = true, lsp_fallback = true }
          end
        '';
      }
    ];
    };
  };
}

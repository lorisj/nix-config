{
  flake.modules.nixvim.base = {
    plugins.conform-nvim = {
      enable = true;

      settings = {
        notify_on_error = true;
        format_on_save = ''
          function(bufnr)
              -- disable "format_on_save" lsp_fallback for languages that don't have standard.
              local disable_filetypes = { c = true, cpp = true }
              if disable_filetypes[vim.bo[bufnr].filetype] then 
                  return nul
              else
                  return {
                      timeout_ms = 500,
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
}
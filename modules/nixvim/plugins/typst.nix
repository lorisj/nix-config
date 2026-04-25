{ ... } : {
  flake.nixvimModules.plugins.typst =
    { pkgs, ... }:
    {
      plugins.lsp.servers.tinymist.enable = true;

      extraPlugins = [
        pkgs.vimPlugins.typst-preview-nvim
      ];
      extraConfigLua = ''
        require('typst-preview').setup({})
      '';

      autoCmd = [
        {
          event = "FileType";
          pattern = "typst";
          callback.__raw = ''
            function(args)
              vim.keymap.set("n", "<tab>p", "<cmd>TypstPreview<cr>",
                { buffer = args.buf, desc = "Preview (Typst)" })
              vim.keymap.set("n", "<tab>P", "<cmd>TypstPreviewStop<cr>",
                { buffer = args.buf, desc = "Stop preview (Typst)" })
            end
          '';
        }
      ];
    };
}

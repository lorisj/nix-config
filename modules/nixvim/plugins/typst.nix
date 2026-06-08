{ ... }:
{
  flake.nixvimModules.plugins.typst =
    { config, pkgs, ... }:
    let
      navigationPrefix = config.loris.nixvim.navigationPrefix;
    in
    {
      config = {
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
                vim.keymap.set({ "n", "i" }, "${navigationPrefix}p", "<cmd>TypstPreview<cr>",
                  { buffer = args.buf, desc = "Preview (Typst)" })
                vim.keymap.set({ "n", "i" }, "${navigationPrefix}P", "<cmd>TypstPreviewStop<cr>",
                  { buffer = args.buf, desc = "Stop preview (Typst)" })
              end
            '';
          }
        ];
      };
    };
}

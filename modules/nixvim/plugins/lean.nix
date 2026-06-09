{ ... }:
{
  flake.nixvimModules.plugins.lean =
    { pkgs, ... }:
    {
      config = {
        extraPackages = [
          pkgs.lean4
        ];

        extraPlugins = with pkgs.vimPlugins; [
          lean-nvim
          plenary-nvim
        ];

        extraConfigLua = ''
          require("lean").setup({
            mappings = true,
            lsp = {
              init_options = {
                hasWidgets = true,
              },
            },
            infoview = {
              autoopen = true,
            },
          })
        '';
      };
    };
}

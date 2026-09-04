{ ... }:
{
  flake.nixvimModules.plugins.lean =
    { pkgs, ... }:
    {
      config = {
        extraPackages = [
          # Use elan's lean/lake proxies so each project's lean-toolchain is
          # respected instead of forcing the version currently in nixpkgs.
          pkgs.elan
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

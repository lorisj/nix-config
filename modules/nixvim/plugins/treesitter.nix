{ ... }:
{
  flake.nixvimModules.plugins.treesitter = { ... }: {
    config = {
    plugins.treesitter = {
      enable = true;
      nixvimInjections = true;
      settings = {
        #highlight.enable = true;
        indend.enable = true;
      };
    };
    };
  };
}

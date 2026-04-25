{ ... }:
{
  flake.nixvimModules.plugins.treesitter = { ... }: {
    plugins.treesitter = {
      enable = true;
      nixvimInjections = true;
      settings = {
        #highlight.enable = true;
        indend.enable = true;
      };
    };
  };
}

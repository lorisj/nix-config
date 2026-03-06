{
  flake.modules.nixvim.base.plugins.treesitter = {
    enable = true;
    nixvimInjections = true;
    settings = {
        #highlight.enable = true;
        indend.enable = true;
    };
  };
}


{
  flake.modules.nixvim.base.plugins.comment = {
    enable = true;
    settings = {
      opleader.line = "<leader>c";
      toggler.line = "<leader>/";
    };
  };
}

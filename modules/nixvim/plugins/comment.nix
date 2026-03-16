{
  flake.modules.nixvim.base.plugins.comment = {
    enable = true;
    settings = {
      opleader.line = "<leader>'";
      toggler.line = "<leader>/";
    };
  };
}

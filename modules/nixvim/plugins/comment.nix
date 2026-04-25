{ ... }:
{
  flake.nixvimModules.plugins.comment = { ... }: {
    plugins.comment = {
    enable = true;
    settings = {
      opleader.line = "<leader>/";
      toggler.line = "<leader>/";
    };
  };
  };
}

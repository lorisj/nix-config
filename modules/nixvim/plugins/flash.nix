{ inputs, ... }:
{

  flake.nixvimModules.plugins.flash = { ... }: {
    plugins.flash = {
      enable = true;
    };

    keymaps = [
      {
        key = "<leader>f";
        mode = [ "n" ];
        action = inputs.nixvim.lib.nixvim.mkRaw ''function() require("flash").jump() end'';
        options.desc = "Flash";
      }
    ];

  };
}

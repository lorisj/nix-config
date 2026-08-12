{ inputs, ... }:
{

  flake.nixvimModules.plugins.flash =
    { config, ... }:
    let
      navigationPrefix = config.loris.nixvim.navigationPrefix;
    in
    {
      config = {
        plugins.flash = {
          enable = true;
        };

        keymaps = [
          {
            key = "${navigationPrefix}f";
            mode = [ "n" ];
            action = inputs.nixvim.lib.nixvim.mkRaw ''function() require("flash").jump() end'';
            options.desc = "Flash";
          }
        ];

      };
    };
}

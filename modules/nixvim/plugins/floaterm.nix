{ ... }:
{
  flake.nixvimModules.plugins.floaterm =
    { config, ... }:
    let
      navigationPrefix = config.loris.nixvim.navigationPrefix;
    in
    {
      config = {
        plugins.floaterm = {
          enable = true;
          settings = {
            width = 0.8;
            height = 0.8;
            borderchars = "━┃━┃╭╮╯╰";
            title = "";
          };
        };
        keymaps = [
          {
            mode = [
              "n"
              "i"
            ];
            key = "${navigationPrefix}t";
            action = "<cmd>FloatermToggle<cr>";
            options.desc = "Toggle terminal";
          }
          {
            mode = "t";
            key = "${navigationPrefix}t";
            action = "<cmd>FloatermToggle<cr>";
            options.desc = "Toggle terminal";
          }
        ];
      };
    };
}

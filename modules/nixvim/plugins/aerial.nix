{ ... }:
{
  flake.modules.nixvim.base = {
    plugins.aerial = {
      enable = true;
      settings = {
        attach_mode = "global";
        backends = [
          "treesitter"
          "lsp"
          "markdown"
          "man"
        ];
        keymaps = {
          "<2-LeftMouse>" = "actions.jump";
          "<C-j>" = "actions.down_and_scroll";
          "<C-k>" = "actions.up_and_scroll";
          "?" = "actions.show_help";
        };
      };
    };
    keymaps = [
      {
        mode = "n";
        key = "<Tab>a";
        action = ":AerialToggle<CR>";
      }
    ];

  };
}

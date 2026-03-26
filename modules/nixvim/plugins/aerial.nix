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
          "<CR>" = "actions.jump";
          "j" = "actions.down_and_scroll";
          "k" = "actions.up_and_scroll";
          "?" = "actions.show_help";
        };
      };
    };
    keymaps = [
      {
        mode = ["n" "t"];
        key = "<Tab>a";
        action = "<C-\\><C-n>:AerialToggle<CR>";
      }
    ];

  };
}

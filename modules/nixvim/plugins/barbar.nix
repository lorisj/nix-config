{ ... }:
{
  flake.nixvimModules.plugins.barbar = { ... }: {
    config = {
      plugins.barbar = {
        enable = true;
        settings = {
          animation = true;
          clickable = true;
          insert_at_end = true;
          maximum_length = 24;
          maximum_padding = 2;
          minimum_length = 4;
          minimum_padding = 1;
          no_name_title = "scratch";
          tabpages = false;
          sidebar_filetypes = {
            "neo-tree" = {
              event = "BufWipeout";
              text = "files";
              align = "center";
            };
          };
          icons = {
            button = "×";
            modified.button = "●";
            pinned = {
              button = "󰐃";
              filename = true;
              separator.right = "";
            };
            scroll = {
              left = "‹";
              right = "›";
            };
            separator = {
              left = "";
              right = "";
            };
            current.separator = {
              left = "";
              right = "";
            };
            visible.separator = {
              left = "";
              right = "";
            };
            inactive.separator = {
              left = "";
              right = "";
            };
            separator_at_end = false;
          };
        };
        keymaps = {
          next.key = "K";
          previous.key = "J";
          close = {
            key = "X";
            action = "<Cmd>confirm BufferClose<CR>";
          };
        };
      };
    };
  };
}

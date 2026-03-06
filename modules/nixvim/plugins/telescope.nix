{
  flake.modules.nixvim.base = {
    plugins.telescope = {
      enable = true;
      keymaps = {
        "<leader>ff" = "find_files";
        "<leader>fg" = "live_grep";
        "<leader>b" = "buffers";
        "<leader>fh" = "help_tags";

        "<C-p>" = "git_files";
        "<leader>p" = "old_files";
      };

      settings.defaults = {
        file_ignore_patterns = [
          "^.git/"
          "^.mypy_cache/"
          "^__pycache__/"
          "%.ipynb"
          "%.pdf"
          "^node_modules/"
        ];
      };

    };
    keymaps = [
      {
        mode = "n";
        key = "<C-t>";
        action.__raw = ''
          function()
              require('telescope.builtin').live_grep({
                  default_text="TODO",
                  initial_mode="normal"
              })
          end
        '';
      }
    ];
  };
}


{
  flake.modules.nixvim.base = {
    plugins.telescope = {
      enable = true;
      keymaps = {
        "<leader>ff" = "find_files";
        "<leader>fg" = "live_grep";
        "<leader>b" = "buffers";
        "<leader>fh" = "help_tags";

        "<leader>p" = "git_files";
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
    
    userCommands.Todo = {
      command.__raw = ''
        function()
          require('telescope.builtin').live_grep({
            default_text = "TODO",
            initial_mode = "normal"
          })
        end
      '';
      desc = "Search for TODO in project";
    };
  };
}


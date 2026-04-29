{ ... }:
{
  flake.nixvimModules.plugins.telescope = { pkgs, ... }: {
    config = {
    extraPackages = with pkgs; [ ripgrep fd ];

    plugins.telescope = {
      enable = true;
      keymaps = {
        "<leader>lg" = "live_grep";
        "<leader>b" = "buffers";
        "<leader>fh" = "help_tags";

        "<leader>gf" = "git_files";
        "<leader>af" = "find_files"; # all files
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
  };
}


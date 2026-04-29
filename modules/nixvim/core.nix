{ ... }:
{
  flake.nixvimModules.core = { ... }: {
    config = {
      plugins = {
        # Lazy loading
        #lz-n.enable = true;
      };
      # Disable netrw to prevent flash on startup
      globals = {
        loaded_netrw = false;
        loaded_netrwPlugin = false;
      };
      plugins.mini-icons.enable = true;

      plugins.web-devicons.enable = true;
      opts = {
        updatetime = 100; # faster completion
        swapfile = false;

        # line numbers
        relativenumber = true;
        number = true; # current line number absolute

        cursorline = true;
        ignorecase = true; # ignore case for search query
        undofile = true;
        autoread = true;

        # tab options
        tabstop = 4;
        shiftwidth = 4; # number of spaces for each step of autoindent
        autoindent = true;
        expandtab = true;
      };
      autoCmd = [
        {
          event = [ "FocusGained" "BufEnter" "CursorHold" "CursorHoldI" ];
          pattern = [ "*" ];
          command = "if mode() != 'c' | checktime | endif";
        }
        # prevents claude from being listed in the buffer list
        {
          event = [ "TermOpen" ];
          pattern = [ "*bin/claude" ];
          command = "set nobuflisted";
        }
      ];
    };
  };
}

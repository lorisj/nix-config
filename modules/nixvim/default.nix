{
  flake.modules.nixvim.base = {
    # viAlias = true;
    # vimAlias = true;
    plugins = {
      # Lazy loading
      lz-n.enable = true;
    };
    # Disable netrw to prevent flash on startup
    globals = {
      loaded_netrw = false;
      loaded_netrwPlugin = false;
    };
    opts = {
      updatetime = 100; # faster completion
      swapfile = false;

      # line numbers
      relativenumber = true;
      number = true; # current line number absolute

      cursorline = true;
      ignorecase = true; # ignore case for search query
      undofile = true;

      # tab options
      tabstop = 4;
      shiftwidth = 4; # number of spaces for each step of autoindent
      autoindent = true;
      expandtab = true;
    };
  };
}

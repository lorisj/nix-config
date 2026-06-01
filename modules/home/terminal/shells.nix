{ ... }:
{
  flake.homeModules.terminal.shells =
    { ... }:
    {
      config = {
        programs.bash = {
          enable = true;
          initExtra = ''
            set -o vi
            bind -m vi-insert '"\C-r": reverse-search-history'
          '';
        };
        programs.zsh = {
          enable = true;
          initContent = ''
            bindkey -v
            bindkey -M viins '^R' history-incremental-search-backward
          '';
        };
      };
    };
}

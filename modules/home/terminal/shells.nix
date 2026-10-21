{ ... }:
{
  flake.homeModules.terminal.shells =
    { ... }:
    {
      config = {
        home.shellAliases.flake-init = "nix flake init -t github:lorisj/nix-config";

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

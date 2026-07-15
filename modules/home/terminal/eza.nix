{ ... }:
{
  flake.homeModules.terminal.eza =
    { config, lib, ... }:
    let
      ezaPkg = config.programs.eza.package;
      # Bash tolerates this; zsh often breaks path completion on multi-word aliases like ls='eza --icons'.
      bashShellAliases = {
        ls = "eza --icons=auto";
      };
    in
    {
      config = {
        programs.eza = {
          enable = true;
        };

        programs.bash = {
          shellAliases = bashShellAliases;
        };

        programs.zsh = {
          # Do not set `programs.zsh.shellAliases.ls` to a multi-word value here — zsh completion
          # after directories is unreliable. HM may still set `ls=eza`; we replace it below.
          initContent = lib.mkIf (ezaPkg != null) (
            lib.mkOrder 1210 ''
              unalias ls 2>/dev/null
              unset -f ls 2>/dev/null
              ls() { command eza --icons=auto "$@"; }
              # Map `ls` onto eza's completion service (`cmd=service`). The reverse (`eza=ls`)
              # would attach _ls to eza and still break paths.
              compdef ls=eza
            ''
          );
        };
      };
    };

}

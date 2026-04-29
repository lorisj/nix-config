{ ... }:
{
  flake.homeModules.terminal.eza =
    { ... }:
    let
      shellAliases = {
        ls = "eza --icons";
      };

    in
    {
      config = {
        programs.eza = {
          enable = true;
        };

        programs.bash = {
          inherit shellAliases;
        };

        programs.zsh = {
          inherit shellAliases;
        };
      };
    };

}

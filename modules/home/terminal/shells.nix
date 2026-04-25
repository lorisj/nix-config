{ ... }:
{
  flake.homeModules.terminal.shells =
    { ... }:
    {
      programs.bash = {
        enable = true;
      };
      programs.zsh = {
        enable = true;
      };
    };
}

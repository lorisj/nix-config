{ ... }:
{
  flake.homeModules.terminal.shells =
    { ... }:
    {
      config = {
        programs.bash = {
          enable = true;
        };
        programs.zsh = {
          enable = true;
        };
      };
    };
}

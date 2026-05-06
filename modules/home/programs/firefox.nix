{ ... }:
{
  flake.homeModules.programs.firefox =
    { ... }:
    {
      config = {
        programs.firefox.enable = true;
      };
    };
}

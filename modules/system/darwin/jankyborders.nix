{ ... }:
{
  flake.darwinModules.jankyborders =
    { ... }:
    {
      services.jankyborders = {
        enable = true;
        style = "round";
        width = 5.0;
        hidpi = true;
      };
    };
}

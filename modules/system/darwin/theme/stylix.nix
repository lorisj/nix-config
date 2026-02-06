{ flake, inputs, ... }:
{
  flake.darwinModules.theme.stylix =
    { ... }:
    {
      imports = [
        inputs.stylix.darwinModules.stylix
      ];
    };
}

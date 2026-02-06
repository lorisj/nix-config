{ flake, ... }: {
  flake.homeModules.shells =
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
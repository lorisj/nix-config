{ ... }:
{
  flake.homeModules.wm.hyprland.cursor =
    { pkgs, lib, config, ... }:
    {
      config = lib.mkIf (pkgs.stdenv.hostPlatform.isLinux && config.wm.hyprland.enable) {
        home.packages = with pkgs; [
          hyprcursor
          volantes-cursors
        ];

        wayland.windowManager.hyprland.settings = {
          input.sensitivity = 0.2;
          env = [
            "XCURSOR_THEME,volantes_cursors"
            "HYPRCURSOR_SIZE,24"
            "XCURSOR_SIZE,24"
            "HYPRCURSOR_THEME,volantes_cursors"
            "WLR_NO_HARDWARE_CURSORS,1"
          ];
        };
      };
    };
}

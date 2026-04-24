{ ... }:
{
    flake.nixosModules.display.hyprland = {config, pkgs, lib, ... } : {
        options = {
            os.display.hyprland.enabled = lib.mkEnableOption "hyprland";
            os.display.hyprland.displayScaling = lib.mkOption {
                type = lib.types.int;
                default = 1;
                description = "Display scaling factor";
            };
        };
        config = lib.mkIf config.os.display.hyprland.enabled {
            programs.hyprland = {
                enable = true;
                xwayland.enable = true;
            };

            environment.systemPackages = with pkgs; [
                waybar
                dunst
                libnotify
            ];


            xdg.portal.enable = true;
            xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];

            environment.sessionVariables = {
                # if cursor becomes invisible enable this:
                #WLR_NO_HARDWARE_CURSORS = "1";

                # hints electron apps to use wayland:
                NIXOS_OZONE_WL = "1";
            };

            hardware = {
                graphics.enable = true;
                nvidia.modesetting.enable = config.os.display.nvidiaEnabled;
            };
        };
    };
}
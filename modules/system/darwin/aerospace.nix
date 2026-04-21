{ lib, ... }:
{
  flake.darwinModules.aerospace =
    { config, ... }:
    let
      m = config.displayModKey;
    in
    {
      options.displayModKey = lib.mkOption {
        type = lib.types.enum [
          "alt"
          "cmd"
          "ctrl"
          "shift"
        ];
        default = "alt";
        description = ''
          Primary modifier for display-oriented key bindings (window management, etc.).
          Values match AeroSpace binding names: cmd, alt, ctrl, shift.
        '';
      };

      config.services.aerospace = {
        enable = true;
        settings = {
          # Managed by nix-darwin launchd — must stay empty/false:
          start-at-login = false;
          after-login-command = [ ];

          config-version = 2;
          accordion-padding = 30;
          after-startup-command = [ ];
          default-root-container-layout = "tiles";
          default-root-container-orientation = "auto";
          enable-normalization-flatten-containers = true;
          enable-normalization-opposite-orientation-for-nested-containers = true;
          exec-on-workspace-change = [ ];
          on-focus-changed = [ ];
          on-focused-monitor-changed = [ "move-mouse monitor-lazy-center" ];
          on-window-detected = [ ];

          # Keep empty named workspaces around (matches AeroSpace default-config idea; trimmed list)
          persistent-workspaces = [
            "1"
            "2"
            "3"
            "4"
            "5"
          ];

          "key-mapping".preset = "qwerty";

          workspace-to-monitor-force-assignment = { };

          # i3-style: focus, move, workspaces — based on AeroSpace default-config.toml
          mode.main.binding = {
            "${m}-j" = "focus left";
            "${m}-l" = "focus down";
            "${m}-h" = "focus up";
            "${m}-k" = "focus right";
            "${m}-shift-h" = "move up";
            "${m}-shift-k" = "move right";
            "${m}-shift-j" = "move left";
            "${m}-shift-l" = "move right";
            "${m}-minus" = "resize smart -50";
            "${m}-equal" = "resize smart +50";
            "${m}-1" = "workspace 1";
            "${m}-2" = "workspace 2";
            "${m}-3" = "workspace 3";
            "${m}-4" = "workspace 4";
            "${m}-5" = "workspace 5";
            "${m}-shift-1" = "move-node-to-workspace 1";
            "${m}-shift-2" = "move-node-to-workspace 2";
            "${m}-shift-3" = "move-node-to-workspace 3";
            "${m}-shift-4" = "move-node-to-workspace 4";
            "${m}-shift-5" = "move-node-to-workspace 5";
            "${m}-tab" = "workspace-back-and-forth";
            #"${m}-leftSquareBracket" = "workspace --wrap-around prev";
            #"${m}-rightSquareBracket" = "workspace --wrap-around next";
          };
        };
      };
    };
}

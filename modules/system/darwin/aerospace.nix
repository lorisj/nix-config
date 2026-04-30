{ lib, ... }:
{
  flake.darwinModules.aerospace =
    { config, ... }:
    let
      m = config.displayModKey;
      workspaces = [
        0
        1
        2
        3
        4
        5
        6
        7
        8
        9
      ];
      # bindings for switching workspaces
      persistent-workspace-names = map builtins.toString workspaces;
      workspace-switch-bindings = lib.listToAttrs (
        map (w: {
          name = "${m}-${builtins.toString w}";
          value = "workspace ${builtins.toString w}";
        }) workspaces
      );
      move-to-workspace-bindings = lib.listToAttrs (
        map (w: {
          name = "${m}-shift-${builtins.toString w}";
          value = "move-node-to-workspace ${builtins.toString w}";
        }) workspaces
      );
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

      config = lib.mkMerge [
        {
          services.aerospace = {
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
              persistent-workspaces = persistent-workspace-names;

              "key-mapping".preset = "qwerty";

              workspace-to-monitor-force-assignment = { };

              # i3-style: focus, move, workspaces — based on AeroSpace default-config.toml
              mode.main.binding =
                {
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
                  # "${m}-tab" = "workspace-back-and-forth";

                  # TODO: move into option
                  # -na => open new instance if already running
                  "${m}-enter" = "exec-and-forget open -na kitty";

                  "${m}-b" = ''exec-and-forget open -na "Google Chrome"'';
                  #"${m}-leftSquareBracket" = "workspace --wrap-around prev";
                  #"${m}-rightSquareBracket" = "workspace --wrap-around next";
                }
                // workspace-switch-bindings
                // move-to-workspace-bindings;
            };
          };
        }
        (lib.mkIf (m == "cmd") {
          # Frees ⌘⇧4 / ⌘⇧5 for `move-node-to-workspace`:
          # 30 = "Save picture of selected area" (saveSelectionToFile)
          # 184 = "Screenshot and recording options" (Screenshot & Screen Recording)
          system.defaults.CustomUserPreferences."com.apple.symbolichotkeys" = {
            AppleSymbolicHotKeys = {
              "30".enabled = false;
              "184".enabled = false;
            };
          };
        })
      ];
    };
}

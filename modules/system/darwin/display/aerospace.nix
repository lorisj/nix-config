{ lib, ... }:
{
  flake.darwinModules.display.aerospace =
    { config, pkgs, ... }:
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
      refreshSketchybar = "exec-and-forget ${pkgs.sketchybar}/bin/sketchybar --trigger aerospace_workspace_change";
      withRefresh =
        command:
        if builtins.isList command then
          command ++ [ refreshSketchybar ]
        else
          [
            command
            refreshSketchybar
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
          value = withRefresh "move-node-to-workspace ${builtins.toString w}";
        }) workspaces
      );
      refresh-bindings = {
        "${m}-shift-h" = withRefresh "move left";
        "${m}-shift-j" = withRefresh "move up";
        "${m}-shift-k" = withRefresh "move down";
        "${m}-shift-l" = withRefresh "move right";
      };
      appOnFocusedWorkspaceLauncher = pkgs.writeShellApplication {
        name = "open-app-on-focused-workspace";
        runtimeInputs = [ pkgs.aerospace ];
        text = ''
          if [[ "$#" -ne 2 ]]; then
            echo "usage: open-app-on-focused-workspace APP_NAME BUNDLE_ID" >&2
            exit 64
          fi

          app_name="$1"
          bundle_id="$2"
          target_workspace="$(aerospace list-workspaces --focused)"

          declare -A existing_windows=()
          while IFS= read -r window_id; do
            if [[ -n "$window_id" ]]; then
              existing_windows["$window_id"]=1
            fi
          done < <(aerospace list-windows --all \
            --app-bundle-id "$bundle_id" \
            --format '%{window-id}')

          # Avoid activating an existing app window on another workspace
          # before the requested new window has been created.
          /usr/bin/open -g -n -a "$app_name"

          for _ in {1..100}; do
            while IFS= read -r window_id; do
              if [[ -n "$window_id" && -z "''${existing_windows[$window_id]+x}" ]]; then
                aerospace move-node-to-workspace \
                  --window-id "$window_id" \
                  --focus-follows-window \
                  "$target_workspace"
                exit 0
              fi
            done < <(aerospace list-windows --all \
              --app-bundle-id "$bundle_id" \
              --format '%{window-id}')

            sleep 0.05
          done

          exit 1
        '';
      };
      # Fixes apps opening on their previous workspace when launched from an empty workspace.
      # Apps currently known to need this workaround: Google Chrome.
      openAppOnFocusedWorkspace =
        { appName, bundleId }:
        "exec-and-forget ${appOnFocusedWorkspaceLauncher}/bin/open-app-on-focused-workspace "
        + lib.escapeShellArgs [
          appName
          bundleId
        ];
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
          # Keep app activation on the focused AeroSpace workspace. Without
          # this, macOS jumps to a Space that already has a window for the app
          # before opening another window (notably with Chrome).
          system.defaults.NSGlobalDomain.AppleSpacesSwitchOnActivate = false;

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

              gaps = {
                inner.horizontal = 15;
                inner.vertical = 15;
                outer.left = 20;
                outer.bottom = 45;
                outer.right = 20;
                outer.top = 20;
              };

              workspace-to-monitor-force-assignment = { };

              # i3-style: focus, move, workspaces — based on AeroSpace default-config.toml
              mode.main.binding = {
                "${m}-h" = "focus left";
                "${m}-j" = "focus up";
                "${m}-k" = "focus down";
                "${m}-l" = "focus right";
                "${m}-minus" = "resize smart -50";
                "${m}-equal" = "resize smart +50";
                # "${m}-tab" = "workspace-back-and-forth";

                # TODO: move into option
                # -na => open new instance if already running
                "${m}-enter" = "exec-and-forget open -na kitty";

                "${m}-b" = openAppOnFocusedWorkspace {
                  appName = "Google Chrome";
                  bundleId = "com.google.Chrome";
                };
                #"${m}-leftSquareBracket" = "workspace --wrap-around prev";
                #"${m}-rightSquareBracket" = "workspace --wrap-around next";
              }
              // refresh-bindings
              // workspace-switch-bindings
              // move-to-workspace-bindings;
            };
          };
        }
        (lib.mkIf (m == "cmd") {
          # Frees ⌘⇧3 / ⌘⇧4 / ⌘⇧5 for `move-node-to-workspace`:
          # 28 = "Save picture of screen as a file" (saveScreenToFile)
          # 30 = "Save picture of selected area" (saveSelectionToFile)
          # 184 = "Screenshot and recording options" (Screenshot & Screen Recording)
          system.defaults.CustomUserPreferences."com.apple.symbolichotkeys" = {
            AppleSymbolicHotKeys = {
              "28".enabled = false;
              "30".enabled = false;
              "184".enabled = false;
            };
          };
        })
      ];
    };
}

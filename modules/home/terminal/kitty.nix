{ flake, ... }:
{
  flake.homeModules.kitty =
    { pkgs, lib, ... }:
    {
      # Dock / Spotlight / Finder: Launch Services does not pass argv; this file
      # supplies CLI flags (see kitty --help --start-as).
      xdg.configFile."kitty/macos-launch-services-cmdline" = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
        text = "--start-as=maximized\n";
      };

      programs.kitty = {
        enable = true;

        # Shell / `nix run` / anything that executes $out/bin/kitty — unlike
        # macos-launch-services-cmdline, which only applies to GUI launches.
        package = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin (
          pkgs.symlinkJoin {
            name = "kitty-wrapped";
            paths = [ pkgs.kitty ];
            nativeBuildInputs = [ pkgs.makeWrapper ];
            postBuild = ''
              wrapProgram $out/bin/kitty --add-flags "--start-as=maximized"
            '';
          }
        );

        font = lib.mkForce {
          package = pkgs.fantasque-sans-mono;
          name = "Fantasque Sans Mono";
          size = 14.0;
        };

        shellIntegration.mode = "no-cursor";

        settings = {
          italic_font = "auto";
          bold_font = "auto";
          bold_italic_font = "auto";
          # force bc stylix will try to overwrite this
          background_opacity = lib.mkForce 0.82;

          cursor_shape = "block";
          cursor_blink_interval = 0.5;
          cursor_stop_blinking_after = 15.0;


          remember_window_size = false;
          repaint_delay = 10;
          input_delay = 3;

          open_url_with = "default";
          term = "xterm-kitty";

          window_border_width = 0;
          window_margin_width = 15;

          hide_window_decorations = "titlebar-only";
          macos_titlebar_color = "background";
          macos_traditional_fullscreen = true;
        };
      };
    };
}

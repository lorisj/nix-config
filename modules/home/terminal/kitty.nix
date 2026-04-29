{ ... }:
{
  flake.homeModules.terminal.kitty =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {
      # Dock / Spotlight / Finder: Launch Services does not pass argv; this file
      # supplies CLI flags (see kitty --help --start-as).
      # xdg.configFile."kitty/macos-launch-services-cmdline" = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
      #   text = "--start-as=maximized\n";
      # };
      config = {
        programs.kitty = {
          enable = true;

          font = lib.mkForce {
            package = pkgs.iosevka;
            name = "Iosevka";
            size = 16.0;
          };

          #shellIntegration.mode = "no-cursor";

          settings = {
            italic_font = "auto";
            bold_font = "auto";
            bold_italic_font = "auto";
            # force bc stylix will try to overwrite this
            background_opacity = lib.mkForce 0.82;

            cursor_shape = "block";
            cursor_blink_interval = 0.5;
            cursor_stop_blinking_after = 15.0;

            cursor_trail = 1;
            # Palette hex has no leading # (same as nixvim); prepend once to avoid ##
            cursor_trail_color = "#" + config.colorScheme.palette.base0C;
            cursor_trail_decay = "0.1 0.2";

            remember_window_size = false;

            open_url_with = "default";

            # === Trying to fix issues w/ repainting / etc ===

            #term = "xterm";
            #term = "xterm-256color";
            term = "xterm-kitty";
            disable_ligatures = "always";
            repaint_delay = 10;
            input_delay = 8;
            sync_to_monitor = "no";
            macos_render_timer = 10;

            # =======

            window_border_width = 0;
            window_margin_width = 15;

            hide_window_decorations = "titlebar-only";
            macos_titlebar_color = "background";
            macos_traditional_fullscreen = true;
          };
        };
    };
  };
}

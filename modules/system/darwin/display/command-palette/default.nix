{ ... }:
{
  flake.darwinModules.display.command-palette =
    { lib, pkgs, ... }:
    let
      quickAccessConfig = pkgs.writeText "command-palette.conf" ''
        edge center-sized
        columns 680px
        lines 340px
        layer overlay
        background_opacity 0.8
        hide_on_focus_loss yes

        kitty_override background_blur=0
        kitty_override background_image=none
        kitty_override cursor_trail=0
        kitty_override input_delay=1
        kitty_override repaint_delay=2
        kitty_override sync_to_monitor=yes
      '';

      paletteZshConfig = pkgs.writeTextDir ".zshrc" ''
        PATH="$HOME/.nix-profile/bin:/etc/profiles/per-user/$USER/bin:/run/current-system/sw/bin:/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
        cd "$HOME"
        HISTFILE="$HOME/.zsh_history"
        HISTSIZE=10000
        SAVEHIST=10000
        PROMPT='%F{cyan}❯%f '
        RPROMPT='%F{8}%~%f'
        setopt append_history

        command-palette-exit() {
          exit
        }

        zle -N command-palette-exit
        bindkey '^[' command-palette-exit
      '';

      commandPalette = pkgs.writeShellApplication {
        name = "command-palette";
        runtimeInputs = [ pkgs.kitty ];
        text = ''
          exec kitten quick-access-terminal \
            --config ${quickAccessConfig} \
            --instance-group command-palette \
            ${pkgs.coreutils}/bin/env ZDOTDIR=${paletteZshConfig} \
              ${pkgs.zsh}/bin/zsh -i
        '';
      };
    in
    {
      config = {
        environment.systemPackages = [ commandPalette ];

        services.aerospace.settings.mode.main.binding.cmd-e =
          "exec-and-forget ${lib.getExe commandPalette}";
      };
    };
}

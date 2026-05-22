{ ... }:
{
  # Status-line + Claude Code UI theme use `config.colorScheme.palette` (nix-colors), same idea as starship.
  # Test the script: `nix eval --raw '.#darwinConfigurations.<host>.config.home-manager.users.<user>.programs.claude-code.settings.statusLine.command'` then pipe sample JSON into that path.
  flake.homeModules.editor.claude-code =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      palette = config.colorScheme.palette;

      hexWithHash = base: "#" + palette.${base};

      hexToRgb =
        hex:
        let
          h = lib.toLower (lib.removePrefix "#" hex);
          n = lib.fromHexString h;
        in
        {
          r = builtins.bitAnd 255 (builtins.div n 65536);
          g = builtins.bitAnd 255 (builtins.div n 256);
          b = builtins.bitAnd 255 n;
        };

      rgb =
        base:
        let
          t = hexToRgb (hexWithHash base);
        in
        "rgb(${toString t.r},${toString t.g},${toString t.b})";

      jsonFormat = pkgs.formats.json { };

      # Claude Code ~/.claude/themes/<id>.json — keys from upstream theme shape, values from base16 roles.
      ccThemeId = "nix-base16";
      ccThemeColors = {
        autoAccept = rgb "base0A";
        bashBorder = rgb "base02";
        claude = rgb "base0C";
        claudeShimmer = rgb "base0C";
        clawd_body = rgb "base0C";
        claudeBlue_FOR_SYSTEM_SPINNER = rgb "base0D";
        claudeBlueShimmer_FOR_SYSTEM_SPINNER = rgb "base07";
        permission = rgb "base0D";
        permissionShimmer = rgb "base07";
        planMode = rgb "base0E";
        ide = rgb "base05";
        promptBorder = rgb "base03";
        promptBorderShimmer = rgb "base04";
        text = rgb "base05";
        inverseText = rgb "base02";
        inactive = rgb "base04";
        subtle = rgb "base03";
        suggestion = rgb "base06";
        remember = rgb "base05";
        background = rgb "base00";
        success = rgb "base0B";
        error = rgb "base08";
        warning = rgb "base0A";
        warningShimmer = rgb "base0B";
        diffAdded = rgb "base0B";
        diffRemoved = rgb "base08";
        diffAddedDimmed = rgb "base02";
        diffRemovedDimmed = rgb "base01";
        diffAddedWord = rgb "base07";
        diffRemovedWord = rgb "base08";
        diffAddedWordDimmed = rgb "base06";
        diffRemovedWordDimmed = rgb "base04";
        red_FOR_SUBAGENTS_ONLY = rgb "base08";
        blue_FOR_SUBAGENTS_ONLY = rgb "base0D";
        green_FOR_SUBAGENTS_ONLY = rgb "base0B";
        yellow_FOR_SUBAGENTS_ONLY = rgb "base0A";
        purple_FOR_SUBAGENTS_ONLY = rgb "base0E";
        orange_FOR_SUBAGENTS_ONLY = rgb "base09";
        pink_FOR_SUBAGENTS_ONLY = rgb "base0F";
        cyan_FOR_SUBAGENTS_ONLY = rgb "base0C";
        professionalBlue = rgb "base0D";
        rainbow_red = rgb "base08";
        rainbow_orange = rgb "base09";
        rainbow_yellow = rgb "base0A";
        rainbow_green = rgb "base0B";
        rainbow_blue = rgb "base0D";
        rainbow_indigo = rgb "base0E";
        rainbow_violet = rgb "base0F";
        rainbow_red_shimmer = rgb "base07";
        rainbow_orange_shimmer = rgb "base07";
        rainbow_yellow_shimmer = rgb "base07";
        rainbow_green_shimmer = rgb "base07";
        rainbow_blue_shimmer = rgb "base07";
        rainbow_indigo_shimmer = rgb "base07";
        rainbow_violet_shimmer = rgb "base07";
        clawd_background = rgb "base00";
        userMessageBackground = rgb "base01";
        bashMessageBackgroundColor = rgb "base02";
        memoryBackgroundColor = rgb "base01";
        rate_limit_fill = rgb "base0B";
        rate_limit_empty = rgb "base03";
      };

      ccTheme = {
        name = "Nix base16";
        id = ccThemeId;
        base = "dark";
        overrides = ccThemeColors;
      };

      # Bash printf format: truecolor fg/bg then %s cell, then reset (same idea as starship segments).
      fmtSeg =
        fgBase: bgBase:
        let
          fg = hexToRgb (hexWithHash fgBase);
          bg = hexToRgb (hexWithHash bgBase);
        in
        "\\033[38;2;${toString fg.r};${toString fg.g};${toString fg.b}m"
        + "\\033[48;2;${toString bg.r};${toString bg.g};${toString bg.b}m %s \\033[0m";

      dirFmt = fmtSeg "base07" "base0A";
      gitFmt = fmtSeg "base07" "base0B";
      modelFmt = fmtSeg "base07" "base0C";
      # Same as starship `[nix_shell]` (`style = "bg:#base0D fg:#base07"`).
      ctxFmt = fmtSeg "base07" "base0D";
      # High context usage: same red role as base16 `base08` (e.g. starship errors).
      ctxWarnFmt = fmtSeg "base07" "base08";
      timeFmt = fmtSeg "base0E" "base02";

      statusLineScript = pkgs.writeShellScript "claude-code-status-line" ''
        set -euo pipefail
        # stdin: Claude Code status JSON. One space between each colored block (left-aligned).

        input=$(cat)
        dir=$(echo "$input" | jq -r '.workspace.current_dir')
        if git -C "$dir" rev-parse --git-dir >/dev/null 2>&1; then
          repo=$(basename "$(git -C "$dir" rev-parse --show-toplevel 2>/dev/null)")
        else
          repo=$(basename "$dir")
        fi

        git_branch=$(
          git -C "$dir" -c core.useBuiltinFSMonitor=false rev-parse --abbrev-ref HEAD 2>/dev/null || true
        )
        git_status=$(
          git -C "$dir" -c core.useBuiltinFSMonitor=false status --porcelain 2>/dev/null | wc -l | tr -d ' '
        )
        time=$(date +%R)
        model=$(echo "$input" | jq -r '.model.display_name')
        used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
        remaining_pct=$(echo "$input" | jq -r '.context_window.remaining_percentage // empty')

        ginfo=""
        if [ -n "$git_branch" ]; then
          ginfo="$git_branch"
          [ "$git_status" -gt 0 ] && ginfo="$ginfo +$git_status"
        fi

        chunks=()
        chunks+=("$(printf '${dirFmt}' "$repo")")
        if [ -n "$ginfo" ]; then
          chunks+=("$(printf '${gitFmt}' "$ginfo")")
        fi
        chunks+=("$(printf '${modelFmt}' "$model")")
        if [ -n "$used_pct" ]; then
          ctx_warn=0
          awk "BEGIN{exit !($used_pct+0 > 90)}" >/dev/null 2>&1 && ctx_warn=1
          if [ -n "$remaining_pct" ]; then
            awk "BEGIN{exit !($remaining_pct+0 < 10)}" >/dev/null 2>&1 && ctx_warn=1
          fi
          if [ "$ctx_warn" -eq 1 ]; then
            chunks+=("$(printf '${ctxWarnFmt}' "⚠️ $used_pct%")")
          else
            chunks+=("$(printf '${ctxFmt}' "$used_pct%")")
          fi
        fi
        chunks+=("$(printf '${timeFmt}' "⏰ $time")")

        ( IFS=' '; printf '%s\n' "''${chunks[*]}")
      '';
    in
    {
      config = {
        home.file.".claude/themes/${ccThemeId}.json".source =
          jsonFormat.generate "claude-code-theme-${ccThemeId}.json" ccTheme;

        programs.claude-code = {
          enable = true;
          settings = {
            statusLine = {
              type = "command";
              command = "${statusLineScript}";
            };
            alwaysThinkingEnabled = true;
            theme = "custom:${ccThemeId}";
            editorMode = "vim";
            autoCompactEnabled = false;
          };
        };
      };
    };
}

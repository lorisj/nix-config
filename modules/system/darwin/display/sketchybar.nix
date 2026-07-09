{ self, ... }:
{
  flake.darwinModules.display.sketchybar =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      palette = config.home-manager.users.${config.system.primaryUser}.colorScheme.palette;
      # TODO: generalized option for font
      textFont =
        config.home-manager.users.${config.system.primaryUser}.programs.kitty.font.name or "Iosevka";
      alpha = opacity: base: "0x${opacity}${palette.${base}}";
      colors = {
        surface = alpha "a6" "base00";
        text = alpha "ff" "base07";
        border = alpha "dd" "base03";
        selected = alpha "ff" "base0D";
        selectedText = alpha "ff" "base00";
        accent = alpha "ff" "base0C";
        frontApp = alpha "a6" "base00";
        caltrain = alpha "a6" "base00";
        wifi = alpha "a6" "base00";
        volume = alpha "a6" "base00";
        battery = alpha "a6" "base00";
        time = alpha "a6" "base00";
        frontAppBorder = alpha "ff" "base08";
        caltrainBorder = alpha "ff" "base0D";
        wifiBorder = alpha "ff" "base0B";
        volumeBorder = alpha "ff" "base0C";
        batteryBorder = alpha "ff" "base0A";
        timeBorder = alpha "ff" "base0E";
        accentText = alpha "ff" "base07";
        batteryAccent = alpha "ff" "base0A";
        wifiAccent = alpha "ff" "base0B";
      };
      iconDir = self.assetPaths.programIcons;
      caltrainPlugin = pkgs.replaceVarsWith {
        src = ./plugins/caltrain.js;
        isExecutable = true;
        replacements = {
          node = "${pkgs.nodejs}/bin/node";
        };
      };
      configDir = pkgs.runCommand "sketchybar-pill-config" { } ''
        mkdir -p $out/plugins

        cp ${./sketchybar/sketchybarrc.zsh} $out/sketchybarrc
        cp ${./sketchybar/plugins}/*.sh $out/plugins/

        substituteInPlace $out/sketchybarrc \
          --replace "@pluginDir@" "$out/plugins" \
          --replace "@zsh@" "${pkgs.zsh}" \
          --replace "@sketchybar@" "${pkgs.sketchybar}" \
          --replace "@aerospace@" "${pkgs.aerospace}" \
          --replace "@iconDir@" "${iconDir}" \
          --replace "@surface@" "${colors.surface}" \
          --replace "@text@" "${colors.text}" \
          --replace "@border@" "${colors.border}" \
          --replace "@selected@" "${colors.selected}" \
          --replace "@selectedText@" "${colors.selectedText}" \
          --replace "@accent@" "${colors.accent}" \
          --replace "@frontApp@" "${colors.frontApp}" \
          --replace "@caltrain@" "${colors.caltrain}" \
          --replace "@wifi@" "${colors.wifi}" \
          --replace "@volume@" "${colors.volume}" \
          --replace "@battery@" "${colors.battery}" \
          --replace "@time@" "${colors.time}" \
          --replace "@frontAppBorder@" "${colors.frontAppBorder}" \
          --replace "@caltrainBorder@" "${colors.caltrainBorder}" \
          --replace "@wifiBorder@" "${colors.wifiBorder}" \
          --replace "@volumeBorder@" "${colors.volumeBorder}" \
          --replace "@batteryBorder@" "${colors.batteryBorder}" \
          --replace "@timeBorder@" "${colors.timeBorder}" \
          --replace "@accentText@" "${colors.accentText}" \
          --replace "@batteryAccent@" "${colors.batteryAccent}" \
          --replace "@wifiAccent@" "${colors.wifiAccent}" \
          --replace "@textFont@" "${textFont}"

        substituteInPlace $out/plugins/*.sh \
          --replace "@sketchybar@" "${pkgs.sketchybar}" \
          --replace "@aerospace@" "${pkgs.aerospace}" \
          --replace "@caltrainPlugin@" "${caltrainPlugin}" \
          --replace "@iconDir@" "${iconDir}" \
          --replace "@text@" "${colors.text}" \
          --replace "@selected@" "${colors.selected}" \
          --replace "@selectedText@" "${colors.selectedText}"

        chmod +x $out/sketchybarrc $out/plugins/*.sh
      '';
    in
    {
      config = {
        environment.systemPackages = with pkgs; [
          sketchybar
          nerd-fonts.symbols-only
        ];
        fonts.packages = [ pkgs.iosevka ];

        system.defaults.NSGlobalDomain._HIHideMenuBar = true;

        services.aerospace.settings.exec-on-workspace-change = lib.mkAfter [
          "${pkgs.bash}/bin/bash"
          "-c"
          "${pkgs.sketchybar}/bin/sketchybar --trigger aerospace_workspace_change FOCUSED_WORKSPACE=$AEROSPACE_FOCUSED_WORKSPACE PREV_WORKSPACE=$AEROSPACE_PREV_WORKSPACE"
        ];

        services.aerospace.settings.on-window-detected = lib.mkAfter [
          {
            run = "exec-and-forget ${pkgs.sketchybar}/bin/sketchybar --trigger aerospace_workspace_change";
          }
        ];

        services.aerospace.settings.on-focus-changed = lib.mkAfter [
          "exec-and-forget ${pkgs.sketchybar}/bin/sketchybar --trigger aerospace_workspace_change"
        ];

        launchd.user.agents.sketchybar = {
          serviceConfig = {
            ProgramArguments = [
              "${pkgs.sketchybar}/bin/sketchybar"
              "--config"
              "${configDir}/sketchybarrc"
            ];
            KeepAlive = true;
            RunAtLoad = true;
            StandardOutPath = "/tmp/sketchybar.out.log";
            StandardErrorPath = "/tmp/sketchybar.err.log";
          };
        };
      };
    };
}

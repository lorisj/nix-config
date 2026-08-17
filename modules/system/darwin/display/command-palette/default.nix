{ ... }:
{
  flake.darwinModules.display.command-palette =
    { pkgs, ... }:
    let
      infoPlist = pkgs.writeText "command-palette-info.plist" ''
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
        <plist version="1.0"><dict>
          <key>CFBundleExecutable</key><string>CommandPalette</string>
          <key>CFBundleIdentifier</key><string>dev.loris.command-palette</string>
          <key>CFBundleName</key><string>Command Palette</string>
          <key>CFBundlePackageType</key><string>APPL</string>
          <key>CFBundleShortVersionString</key><string>0.1.0</string>
          <key>LSMinimumSystemVersion</key><string>13.0</string>
          <key>LSUIElement</key><true/>
          <key>NSHighResolutionCapable</key><true/>
        </dict></plist>
      '';
      commandPalette = pkgs.stdenv.mkDerivation {
        pname = "command-palette";
        version = "0.1.0";
        dontUnpack = true;
        nativeBuildInputs = [ pkgs.swift ];
        buildPhase = ''
          swiftc -O -framework AppKit -framework Carbon \
            ${./CommandPalette.swift} -o CommandPalette
        '';
        installPhase = ''
          app="$out/Applications/Command Palette.app"
          mkdir -p "$app/Contents/MacOS"
          cp CommandPalette "$app/Contents/MacOS/CommandPalette"
          cp ${infoPlist} "$app/Contents/Info.plist"
        '';
      };
    in
    {
      config = {
        environment.systemPackages = [ commandPalette ];
        launchd.user.agents.command-palette.serviceConfig = {
          ProgramArguments = [
            "${commandPalette}/Applications/Command Palette.app/Contents/MacOS/CommandPalette"
          ];
          KeepAlive = true;
          RunAtLoad = true;
          ProcessType = "Interactive";
        };
      };
    };
}

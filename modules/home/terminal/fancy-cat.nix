{ ... }:
{
  flake.homeModules.terminal.fancy-cat =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      appleSdk = pkgs."apple-sdk_15";
      zigPackages = pkgs.callPackage "${pkgs.path}/pkgs/by-name/fa/fancy-cat/build.zig.zon.nix" { };
      fancyCat = pkgs.fancy-cat.overrideAttrs (oldAttrs: {
        buildInputs =
          (oldAttrs.buildInputs or [ ])
          ++ lib.optionals pkgs.stdenv.hostPlatform.isDarwin [
            appleSdk
          ];
        env = (oldAttrs.env or { }) // {
          NIX_CFLAGS_COMPILE =
            (oldAttrs.env.NIX_CFLAGS_COMPILE or oldAttrs.NIX_CFLAGS_COMPILE or "")
            + lib.optionalString pkgs.stdenv.hostPlatform.isDarwin (
              " -isystem ${appleSdk.sdkroot}/usr/include -iframework ${appleSdk.sdkroot}/System/Library/Frameworks"
            );
          NIX_LDFLAGS =
            (oldAttrs.env.NIX_LDFLAGS or oldAttrs.NIX_LDFLAGS or "")
            + lib.optionalString pkgs.stdenv.hostPlatform.isDarwin " -L${appleSdk.sdkroot}/usr/lib";
        };
        postConfigure = ''
          mkdir -p "$ZIG_GLOBAL_CACHE_DIR/p"
          cp -R -L ${zigPackages}/* "$ZIG_GLOBAL_CACHE_DIR/p/"
          chmod -R u+w "$ZIG_GLOBAL_CACHE_DIR/p"
        '';
        postPatch = (oldAttrs.postPatch or "") + ''
          substituteInPlace build.zig.zon \
            --replace-fail \
              "https://github.com/freref/fzwatch/archive/refs/heads/master.tar.gz" \
              "https://github.com/freref/fzwatch/archive/6d5b49ed5a8ee3ed08f0e80b8f340cc3c8c8ac6e.tar.gz"
          substituteInPlace build.zig \
            --replace-fail '        exe.addIncludePath(.{ .cwd_relative = "/opt/homebrew/include" });' "" \
            --replace-fail '        exe.addLibraryPath(.{ .cwd_relative = "/opt/homebrew/lib" });' "" \
            --replace-fail '        exe.addIncludePath(.{ .cwd_relative = "/usr/local/include" });' "" \
            --replace-fail '        exe.addLibraryPath(.{ .cwd_relative = "/usr/local/lib" });' ""
        '';
        meta = oldAttrs.meta // {
          broken = false;
        };
      });
    in
    {
      # Dock / Spotlight / Finder: Launch Services does not pass argv; this file
      # supplies CLI flags (see kitty --help --start-as).
      # xdg.configFile."kitty/macos-launch-services-cmdline" = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
      #   text = "--start-as=maximized\n";
      # };
      config = {
        home.packages = [
          pkgs.pixcat
          fancyCat
        ];
      };
    };
}

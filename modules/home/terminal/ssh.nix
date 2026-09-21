{ ... }:
{
  flake.homeModules.terminal.ssh =
    { lib, pkgs, ... }:
    {
      config = {
        programs.ssh = {
          enable = true;
          enableDefaultConfig = false;
          settings."*" = {
            AddKeysToAgent = "yes";
            IdentityFile = [ "~/.ssh/id_ed25519" ];
          }
          // lib.optionalAttrs pkgs.stdenv.hostPlatform.isDarwin {
            # Keep using Apple's SSH client for persistent Keychain passphrases.
            IgnoreUnknown = "UseKeychain";
            UseKeychain = true;
          };
        };

        # macOS already provides an agent through launchd.
        services.ssh-agent.enable = lib.mkDefault pkgs.stdenv.hostPlatform.isLinux;
      };
    };
}

{ self, ... }:
{
  flake.osModules.networking.ssh =
    { config, lib, ... }:
    let
      cfg = config.os.networking.ssh;
    in
    {
      options = {
        os.networking.ssh.enabled = lib.mkEnableOption "ssh";

        os.networking.ssh.allowedUsers = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = lib.sort lib.lessThan (lib.attrNames config.os.users);
          description = "Users allowed to SSH into this host.";
        };
      };

      config = lib.mkIf cfg.enabled {
        services.openssh = {
          enable = true;
          settings = {
            PasswordAuthentication = false;
            KbdInteractiveAuthentication = false;
            PermitRootLogin = "no";
            AllowUsers = cfg.allowedUsers;
          };
        };

        users.users = builtins.listToAttrs (
          builtins.map (userName: {
            name = userName;
            value.openssh.authorizedKeys.keys = self.userConfig.${userName}.nixos.sshKeys;
          }) cfg.allowedUsers
        );
      };
    };
}

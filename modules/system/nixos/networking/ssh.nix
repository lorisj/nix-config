{ lib, self, ... }:
let
  userNames = lib.sort lib.lessThan (lib.attrNames self.userConfig);

  defaultKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICeZI2pBSxv1fs6V8hAe5DDyHSUT4UCcQZTXK9sLPxwt"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOgykMePA2aCBXm2uktQSnI4p4f0++eWZ5hYF80vtrMo"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFZU98KS18bZSgmD7xsKozlldpneJW8zlgzi5HvxWog0"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDHszkI7lSEaP7U/9Q6CwKKbaeFLD9OUEy3MbtW1XsOX"
  ];
in
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
          default = userNames;
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
            value.openssh.authorizedKeys.keys = defaultKeys;
          }) cfg.allowedUsers
        );
      };
    };
}

# `flake.{osModules,sharedModules,darwinModules,nixvimModules,homeModules}` share one leaf type: `customFlakeModuleType`.
# `flake.userConfig` names Home Manager user profiles; attr names are usernames.
{ lib, ... }:
let
  inherit (lib) types;

  customFlakeModuleType =
    let
      moduleOrAttrs =
        depth:
        if depth == 0 then
          types.raw
        else
          types.either (types.lazyAttrsOf (moduleOrAttrs (depth - 1))) types.raw;
    in
    moduleOrAttrs 3;

  userConfigEntry = types.submodule {
    options = {
      module = lib.mkOption {
        type = types.deferredModule;
        description = "Home Manager module for this user (imported from home-manager.users.<name>).";
      };

      nixos.extraGroups = lib.mkOption {
        type = types.listOf types.str;
        default = [ ];
        description = "NixOS groups this user always belongs to, independent of host admin access.";
      };
    };
  };
  hostConfigEntry = types.submodule {
    options = {
      sshHostKey = lib.mkOption {
        type = types.str;
        description = "Public SSH host key (/etc/ssh/ssh_host_ed25519_key.pub); agenix encrypts this host's secrets to it.";
      };
    };
  };
in
{
  options.flake.osModules = lib.mkOption {
    type = types.lazyAttrsOf customFlakeModuleType;
    default = { };
    description = "NixOS modules for this flake (replaces the usual flake.nixosModules registry; use outputs.osModules).";
  };

  options.flake.sharedModules = lib.mkOption {
    type = types.lazyAttrsOf customFlakeModuleType;
    default = { };
  };

  options.flake.darwinModules = lib.mkOption {
    type = types.lazyAttrsOf customFlakeModuleType;
    default = { };
  };

  options.flake.nixvimModules = lib.mkOption {
    type = types.lazyAttrsOf customFlakeModuleType;
    default = { };
  };

  options.flake.homeModules = lib.mkOption {
    type = types.lazyAttrsOf customFlakeModuleType;
    default = { };
  };

  options.flake.userConfig = lib.mkOption {
    type = types.attrsOf userConfigEntry;
    default = { };
    description = "Per-username account profiles. Add a file under users/ to define a new profile.";
  };

  options.flake.sshKeys = lib.mkOption {
    type = types.listOf types.str;
    default = [ ];
    description = "SSH public keys authorized on every host; also the agenix recipients that can edit secrets/.";
  };

  options.flake.hostConfig = lib.mkOption {
    type = types.attrsOf hostConfigEntry;
    default = { };
    description = "Per-host facts read outside the NixOS evaluation, such as by secrets/secrets.nix.";
  };
}

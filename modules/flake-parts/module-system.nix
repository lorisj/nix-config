# `flake.{sharedModules,darwinModules,nixvimModules,homeModules}` share one leaf type: `customFlakeModuleType`.
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
    options.module = lib.mkOption {
      type = types.deferredModule;
      description = "Home Manager module for this user (imported from home-manager.users.<name>).";
    };
  };
in
{
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
    description = "Per-username Home Manager user modules. Add a file under users/ to define a new account profile.";
  };
}

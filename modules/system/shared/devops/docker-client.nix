{ flake, ... }:
let
  sharedModule =
    { config, pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        docker
        docker-credential-helpers
      ];
    };
in
{
  flake.darwinModules.shared.dockerClient = sharedModule;
  flake.nixosModules.shared.dockerClient = sharedModule;

}

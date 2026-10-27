# Recipients for the agenix CLI (run it from this directory); the flake never imports this file.
# Keys come from the flake itself, so changing a key in ssh.nix or hosts/ only needs `agenix -r` here.
let
  flake = builtins.getFlake (toString ../.);
in
{
  "storyteller.env.age".publicKeys = flake.sshKeys ++ [ flake.hostConfig.server.sshHostKey ];
}

# Decrypts secrets/*.age at activation with the host's SSH key; see secrets/secrets.nix.
{ inputs, ... }:
{
  flake.osModules.core.agenix =
    { ... }:
    {
      imports = [ inputs.agenix.nixosModules.default ];
    };
}

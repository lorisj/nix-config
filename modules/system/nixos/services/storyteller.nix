{ inputs, ... }:
{
  flake.osModules.services.storyteller =
    { config, lib, ... }:
    {
      # Defines os.services.storyteller.{enabled,package,environmentFile}.
      imports = [ inputs.storyteller.nixosModules.default ];

      config = lib.mkIf config.os.services.storyteller.enabled {
        # Holds DISCORD_TOKEN=...; edit with `agenix -e storyteller.env.age` in secrets/.
        age.secrets.storyteller-env.file = ../../../../secrets/storyteller.env.age;
        os.services.storyteller.environmentFile = config.age.secrets.storyteller-env.path;
      };
    };
}

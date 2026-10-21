{ ... }:
{
  perSystem =
    { ... }:
    {
      devshells.default = {
        packages = [ ];

        env = [
          # { name = "EXAMPLE"; value = "example"; }
        ];

        devshell.startup.startupScriptName.text = ''
          echo "❄️devshell started"
        '';
      };
    };
}

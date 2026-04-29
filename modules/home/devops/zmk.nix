{ self, ... }:
{
  perSystem =
    { pkgs, self', ... }:
    let
      py = pkgs.python312;
      pyp = py.pkgs;
    in
    {
      packages.zmk = pyp.buildPythonApplication rec {
        pname = "zmk";
        version = "0.4.1";
        pyproject = true;

        src = pkgs.fetchPypi {
          inherit pname version;
          hash = "sha256-vRpzNPW4j6g1N9ZKVBEF6e7Ohwbx/+HrpI4GpyFDVzg=";
        };

        patches = [ ./zmk-west-path.patch ];

        nativeBuildInputs = with pyp; [
          setuptools
          setuptools-scm
        ];

        propagatedBuildInputs = with pyp; [
          dacite
          giturlparse
          mako
          rich
          ruamel-yaml
          shellingham
          typer
          west
        ];

        dontCheckRuntimeDeps = true;

        meta = with pkgs.lib; {
          description = "Command line tool for ZMK Firmware config repos";
          homepage = "https://github.com/zmkfirmware/zmk-cli";
          license = licenses.mit;
          mainProgram = "zmk";
        };
      };

      apps.zmk.program = "${self'.packages.zmk}/bin/zmk";
    };

  flake.homeModules.devops.zmk =
    { pkgs, ... }:
    {
      config = {
        home.packages = [ self.packages.${pkgs.stdenv.hostPlatform.system}.zmk ];
      };
    };
}

{flake,  ...} : {
    flake.darwinModules.test.test = 
    { pkgs, ... }: {
        environment.systemPackages = with pkgs; [
            #local.package1 
        ];
    };
}
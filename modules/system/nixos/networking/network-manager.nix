{...} :
{
    flake.osModules.network.network-manager = { ... } : {
        config = {
            networking.networkmanager.enable = true;
        };
    };
}
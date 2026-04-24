{...} :
{
    flake.nixosModules.network.network-manager = { ... } : {
        config = {
            networking.networkmanager.enable = true;
        };
    };
}
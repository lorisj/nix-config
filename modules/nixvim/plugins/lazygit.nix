{ ... }:
{
    flake.modules.nixvim.base = {
        plugins.lazygit = {
            enable = true;
        };
        keymaps = [
            {
                mode = ["n" "t"];
                key = "<Tab>g";
                action = "<cmd>LazyGit<CR>";
                options.desc = "LazyGit";
            }
        ];
    };
}
{ ... }:
{
    flake.modules.nixvim.base = {
        plugins.lazygit = {
            enable = true;
        };
        keymaps = [
            {
                mode = "n";
                key = "<leader>lg";
                action = ":LazyGit<CR>";
                options.desc = "LazyGit";
            }
        ];
    };
}
{ ... }:
{
    flake.modules.nixvim.base = {
        plugins.lazygit = {
            enable = true;
        };
        keymaps = [
            {
                mode = "n";
                key = "<leader>git";
                action = ":LazyGit<CR>";
                options.desc = "LazyGit";
            }
        ];
    };
}
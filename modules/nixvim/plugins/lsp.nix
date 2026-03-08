{ ... }:
# { lib, ...}:
{
  flake.modules.nixvim.base.plugins.lsp = {
    enable = true;
    inlayHints = true;

    # Configure how diagnostics are displayed
    onAttach = ''
      vim.diagnostic.config({
        virtual_text = true,
        signs = true,
        underline = true,
        update_in_insert = false,
        severity_sort = true,
      })
    '';

    servers = {
      gopls = {
        enable = true;
        autostart = true;
      };
      #ts_ls.enable = true;
      cssls.enable = true;
      tailwindcss.enable = true;
      html.enable = true;
      pyright.enable = true;
      bashls.enable = true;
      hls.enable = true;
      hls.installGhc = true;
      # leanls is handled by lean.nvim plugin, not lspconfig
      nixd = {
        enable = true;
        settings =
          let
            flake2 = ''builtins.getFlake "github:lorisj/private-nixos-config"'';
          in
          {
            nixpkgs = {
              expr = "import ${flake2}.inputs.nixpkgs {}";
            };
            # formatting = {
            #   command = [ "${lib.getExe pkgs.nixfmt-rfc-style}" ];
            # };
            options = {
              # TODO: fix
              nixos.expr = "${flake2}.nixosConfigurations.server.options";

            };
          };
      };
    };
    # https://github.com/Ahwxorg/nixvim-config/blob/master/config/modules/plugins/lsp.nix

    keymaps = {
      silent = true;
      lspBuf = {
        gd = {
          action = "definition";
          desc = "goto definition";
        };
        gr = {
          action = "references";
          desc = "goto references";
        };
        K = {
          action = "hover";
          desc = "show hover information";
        };
        "<leader>rn" = {
          action = "rename";
          desc = "rename symbol";
        };
        "<leader>a" = {
          action = "code_action";
          desc = "code actions";
        };
      };
      diagnostic = {
        "<leader>e" = {
          action = "open_float";
          desc = "show diagnostic in float";
        };
        "[d" = {
          action = "goto_prev";
          desc = "previous diagnostic";
        };
        "]d" = {
          action = "goto_next";
          desc = "next diagnostic";
        };
      };
    };
  };
}

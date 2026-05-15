{ ... }:
{
  flake.nixvimModules.plugins.codex =
    {
      aiAssistant ? "claude-code",
      lib,
      pkgs,
      ...
    }:
    let
      codex-nvim = pkgs.vimUtils.buildVimPlugin {
        name = "codex.nvim";
        src = pkgs.fetchFromGitHub {
          owner = "johnseth97";
          repo = "codex.nvim";
          rev = "e1149cbc875ff71ee21f8832b9fe815a270442b3";
          hash = "sha256-hvBsqLzV3oCVWK4Ll/YDrDhZSTjpvUjTpDQz6SFbtVo=";
        };
      };
    in
    {
      config = lib.mkIf (aiAssistant == "codex") {
        extraPlugins = [
          codex-nvim
        ];
        extraConfigLua = ''
          require('codex').setup({
            keymaps = {
              toggle = nil,
              quit = '<C-q>',
            },
            border = 'rounded',
            width = 0.45,
            height = 0.8,
            autoinstall = false,
            panel = true,
            use_buffer = false,
          })
        '';
        keymaps = [
          {
            mode = [
              "n"
              "t"
            ];
            key = "<tab>c";
            action.__raw = ''
              function()
                local ignored_filetypes = {
                  aerial = true,
                  codex = true,
                  lazygit = true,
                  ["neo-tree"] = true,
                  trouble = true,
                }

                local function is_editor_window(win)
                  if not vim.api.nvim_win_is_valid(win) then
                    return false
                  end

                  local win_config = vim.api.nvim_win_get_config(win)
                  if win_config.relative ~= "" then
                    return false
                  end

                  local buf = vim.api.nvim_win_get_buf(win)
                  return vim.bo[buf].buftype == "" and not ignored_filetypes[vim.bo[buf].filetype]
                end

                if not is_editor_window(vim.api.nvim_get_current_win()) then
                  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
                    if is_editor_window(win) then
                      vim.api.nvim_set_current_win(win)
                      break
                    end
                  end
                end

                vim.cmd("CodexToggle")
                vim.schedule(function()
                  local buf = vim.api.nvim_get_current_buf()
                  if vim.bo[buf].buftype == "terminal" or vim.bo[buf].filetype == "codex" then
                    vim.cmd("startinsert")
                  end
                end)
              end
            '';
            options.desc = "Toggle Codex";
          }
        ];
      };
    };
}

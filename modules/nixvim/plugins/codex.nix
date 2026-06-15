{ ... }:
{
  flake.nixvimModules.plugins.codex =
    {
      aiAssistant ? "claude-code",
      config,
      lib,
      pkgs,
      ...
    }:
    let
      navigationPrefix = config.loris.nixvim.navigationPrefix;
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
              "i"
              "t"
            ];
            key = "${navigationPrefix}c";
            action.__raw = ''
              function()
                local codex = require("codex")
                local codex_state = require("codex.state")

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

                local function find_codex_window()
                  if codex_state.win and vim.api.nvim_win_is_valid(codex_state.win) then
                    return codex_state.win
                  end

                  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
                    local buf = vim.api.nvim_win_get_buf(win)
                    if vim.bo[buf].filetype == "codex" then
                      return win
                    end
                  end
                end

                local current_win = vim.api.nvim_get_current_win()
                local codex_win = find_codex_window()
                if codex_win then
                  if codex_win == current_win then
                    codex.close()
                  else
                    vim.api.nvim_set_current_win(codex_win)
                    vim.cmd("startinsert")
                  end
                  return
                end

                if not is_editor_window(vim.api.nvim_get_current_win()) then
                  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
                    if is_editor_window(win) then
                      vim.api.nvim_set_current_win(win)
                      break
                    end
                  end
                end

                codex.open()
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

{ ... }:
let
  bubbleBase = {
    separator = {
      left = "";
      right = "";
    };
    padding = {
      left = 1;
      right = 1;
    };
  };
  base16Fallbacks = {
    base00 = "#1d2021";
    base02 = "#3c3836";
    base06 = "#ebdbb2";
    base07 = "#fbf1c7";
    base08 = "#fb4934";
    base0A = "#fabd2f";
    base0B = "#b8bb26";
    base0C = "#8ec07c";
    base0D = "#83a598";
    base0E = "#d3869b";
    base0F = "#d65d0e";
  };
  starshipBubble =
    {
      bg,
      fg ? "base07",
      gui ? "",
    }:
    bubbleBase
    // {
      color.__raw = ''
        function()
          local ok, base16 = pcall(require, "base16-colorscheme")
          local colors = ok and base16.colors or {}

          return {
            fg = colors.${fg} or "${base16Fallbacks.${fg}}",
            bg = colors.${bg} or "${base16Fallbacks.${bg}}",
            gui = "${gui}",
          }
        end
      '';
    };

  modeBubble = starshipBubble {
    bg = "base0F";
    gui = "bold";
  };
  osBubble = modeBubble // {
    padding = {
      left = 1;
      right = 1;
    };
  };
  directoryBubble = starshipBubble { bg = "base0A"; };
  gitBubble = starshipBubble { bg = "base0B"; };
  diffBubble = starshipBubble {
    bg = "base07";
    fg = "base00";
  };
  gitDiff = {
    __unkeyed-1.__raw = ''
      function()
        local diff = vim.b.gitsigns_status_dict
        if not diff then
          return ""
        end

        local added = diff.added or 0
        local changed = diff.changed or 0
        local removed = diff.removed or 0

        if added == 0 and changed == 0 and removed == 0 then
          return ""
        end

        local ok, base16 = pcall(require, "base16-colorscheme")
        local colors = ok and base16.colors or {}
        local bg = colors.base07 or "${base16Fallbacks.base07}"

        vim.api.nvim_set_hl(0, "LualineDiffAdded", {
          fg = colors.base0B or "${base16Fallbacks.base0B}",
          bg = bg,
          bold = true,
        })
        vim.api.nvim_set_hl(0, "LualineDiffChanged", {
          fg = colors.base0A or "${base16Fallbacks.base0A}",
          bg = bg,
          bold = true,
        })
        vim.api.nvim_set_hl(0, "LualineDiffRemoved", {
          fg = colors.base08 or "${base16Fallbacks.base08}",
          bg = bg,
          bold = true,
        })

        local parts = {}
        if added > 0 then
          table.insert(parts, "%#LualineDiffAdded#+" .. added)
        end
        if changed > 0 then
          table.insert(parts, "%#LualineDiffChanged#~" .. changed)
        end
        if removed > 0 then
          table.insert(parts, "%#LualineDiffRemoved#-" .. removed)
        end

        return table.concat(parts, " ")
      end
    '';
  };
  languageBubble = starshipBubble { bg = "base0C"; };
  contextBubble = starshipBubble { bg = "base0D"; };
  timeBubble = starshipBubble {
    bg = "base02";
    fg = "base0E";
  };
  positionBubble = {
    __unkeyed-1.__raw = ''
      function()
        local line = vim.fn.line(".")
        local total = vim.fn.line("$")
        local col = vim.fn.charcol(".")
        local progress

        if line == 1 then
          progress = "Top"
        elseif line == total then
          progress = "Bot"
        else
          progress = string.format("%2d%%%%", math.floor(line / total * 100))
        end

        return string.format("%s %3d:%-2d", progress, line, col)
      end
    '';
  }
  // timeBubble;
  prettyFilename = {
    __unkeyed-1.__raw = ''
      function()
        local filetype = vim.bo.filetype
        local buftype = vim.bo.buftype

        if filetype == "codex" then
          return "codex"
        end

        if filetype == "lazygit" then
          return "lazygit"
        end

        if filetype:match("^Neogit") then
          return "neogit"
        end

        if buftype == "terminal" then
          local name = vim.api.nvim_buf_get_name(0)
          local command = name:match(":(.+)$")

          if command and command ~= "" then
            return vim.fn.fnamemodify(command, ":t")
          end

          return "terminal"
        end

        local name = vim.fn.expand("%:~:.")
        if name == "" then
          return "[No Name]"
        end

        local max_width = 48
        if vim.fn.strdisplaywidth(name) > max_width then
          name = vim.fn.pathshorten(name)
        end

        if vim.fn.strdisplaywidth(name) > max_width then
          name = "..." .. name:sub(-max_width + 3)
        end

        return name
      end
    '';
  };
  spacer = {
    __unkeyed-1.__raw = ''
      function()
        return " "
      end
    '';
    separator = {
      left = "";
      right = "";
    };
    padding = {
      left = 0;
      right = 0;
    };
    color = {
      fg = "NONE";
      bg = "NONE";
    };
  };
in
{
  flake.nixvimModules.plugins.lualine = { ... }: {
    config = {
      extraConfigLua = ''
        local function clear_statusline_background()
          for _, group in ipairs({
            "StatusLine",
            "StatusLineNC",
            "StatusLineTerm",
            "StatusLineTermNC",
          }) do
            vim.cmd("highlight " .. group .. " guibg=NONE ctermbg=NONE")
          end
        end

        clear_statusline_background()

        vim.api.nvim_create_autocmd("ColorScheme", {
          callback = clear_statusline_background,
        })
      '';
      highlight = {
        StatusLine.bg = "NONE";
        StatusLineNC.bg = "NONE";
      };
      plugins.lualine = {
        enable = true;
        settings = {
          options = {
            globalstatus = true;
            component_separators = {
              left = "";
              right = "";
            };
            section_separators = {
              left = "";
              right = "";
            };
            theme.__raw = ''
              (function()
                local function hl(name, attr, fallback)
                  local ok, value = pcall(vim.api.nvim_get_hl, 0, { name = name, link = false })
                  local color = ok and value[attr] or nil

                  if color then
                    return string.format("#%06x", color)
                  end

                  return fallback
                end

                local colors = {
                  bg = hl("Normal", "bg", "#1d2021"),
                  fg = hl("Normal", "fg", "#ebdbb2"),
                  muted = hl("Comment", "fg", "#928374"),
                  red = hl("DiagnosticError", "fg", "#fb4934"),
                  yellow = hl("DiagnosticWarn", "fg", "#fabd2f"),
                  green = hl("DiagnosticOk", "fg", "#b8bb26"),
                  blue = hl("Directory", "fg", "#83a598"),
                  purple = hl("Statement", "fg", "#d3869b"),
                }

                local transparent = { fg = colors.fg, bg = "None" }

                return {
                  normal = {
                    a = { fg = colors.bg, bg = colors.blue, gui = "bold" },
                    b = transparent,
                    c = transparent,
                    x = transparent,
                    y = transparent,
                    z = { fg = colors.bg, bg = colors.purple, gui = "bold" },
                  },
                  insert = {
                    a = { fg = colors.bg, bg = colors.green, gui = "bold" },
                    z = { fg = colors.bg, bg = colors.green, gui = "bold" },
                  },
                  visual = {
                    a = { fg = colors.bg, bg = colors.purple, gui = "bold" },
                    z = { fg = colors.bg, bg = colors.purple, gui = "bold" },
                  },
                  replace = {
                    a = { fg = colors.bg, bg = colors.red, gui = "bold" },
                    z = { fg = colors.bg, bg = colors.red, gui = "bold" },
                  },
                  command = {
                    a = { fg = colors.bg, bg = colors.yellow, gui = "bold" },
                    z = { fg = colors.bg, bg = colors.yellow, gui = "bold" },
                  },
                  inactive = {
                    a = { fg = colors.muted, bg = "None" },
                    b = { fg = colors.muted, bg = "None" },
                    c = { fg = colors.muted, bg = "None" },
                  },
                }
              end)()
            '';
          };

          # +-------------------------------------------------+
          # | A | B | C                             X | Y | Z |
          # +-------------------------------------------------+
          sections = {
            lualine_a = [
              ({ __unkeyed-1 = "mode"; } // modeBubble)
              spacer
            ];
            lualine_b = [
              (
                {
                  __unkeyed-1 = "branch";
                  icon = "";
                }
                // gitBubble
              )
              spacer
            ];
            lualine_c = [
              (prettyFilename // directoryBubble)
              spacer
              (gitDiff // diffBubble)
            ];

            lualine_x = [
              (
                {
                  __unkeyed-1 = "diagnostics";
                  symbols = {
                    error = " ";
                    warn = " ";
                    info = " ";
                    hint = "󰌵 ";
                  };
                }
                // timeBubble
              )
              spacer

              # Show active language server.
              (
                {
                  __unkeyed-1.__raw = ''
                    function()
                      local msg = ""
                      local buf_ft = vim.api.nvim_get_option_value("filetype", { buf = 0 })
                      local clients = vim.lsp.get_clients({ bufnr = 0 })

                      if next(clients) == nil then
                        return msg
                      end

                      for _, client in ipairs(clients) do
                        local filetypes = client.config.filetypes
                        if filetypes and vim.fn.index(filetypes, buf_ft) ~= -1 then
                          return client.name
                        end
                      end

                      return msg
                    end
                  '';
                  icon = "";
                }
                // contextBubble
              )
              spacer
              ({ __unkeyed-1 = "encoding"; } // languageBubble)
              spacer
              ({ __unkeyed-1 = "filetype"; } // languageBubble)
              spacer
              ({ __unkeyed-1 = "fileformat"; } // osBubble)
              spacer
              positionBubble
            ];
            lualine_y = [ spacer ];
            lualine_z = [ spacer ];
          };

          inactive_sections = {
            lualine_a = [ ];
            lualine_b = [ ];
            lualine_c = [
              (prettyFilename // directoryBubble)
            ];
            lualine_x = [ spacer ];
            lualine_y = [ spacer ];
            lualine_z = [ spacer ];
          };
        };
      };
    };
  };
}

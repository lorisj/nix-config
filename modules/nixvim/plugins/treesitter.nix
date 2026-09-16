{ ... }:
{
  flake.nixvimModules.plugins.treesitter = { ... }: {
    config = {
      plugins.treesitter = {
        enable = true;
        nixvimInjections = true;
        settings = {
          #highlight.enable = true;
          indend.enable = true;
        };
      };

      plugins.indent-blankline = {
        enable = true;
        settings = {
          indent = {
            char = "│";
            tab_char = "│";
            highlight = "NonText";
          };
          # The hook below highlights the actual fold instead of a syntax scope.
          scope.enabled = false;
        };
      };

      highlight = {
        FoldTreeSelected.link = "Function";
      };

      extraConfigLua = ''
        -- Build a tree from Neovim's evaluated folds, without opening/closing
        -- anything. Start markers distinguish adjacent folds at the same depth.
        local function fold_tree()
          if vim.wo.foldmethod ~= "expr"
            or vim.wo.foldexpr ~= "v:lua.vim.treesitter.foldexpr()" then return {} end
          local roots, stack = {}, {}
          local count = vim.api.nvim_buf_line_count(0)
          for line = 1, count do
            local depth = vim.fn.foldlevel(line)
            local starts = tonumber(vim.treesitter.foldexpr(line):match("^>(%d+)"))
            local keep = starts and math.max(0, math.min(depth, starts - 1)) or depth
            while #stack > keep do
              table.remove(stack).end_line = line - 1
            end
            while #stack < depth do
              local parent = stack[#stack]
              local node = {
                start_line = line, end_line = count, depth = #stack + 1,
                parent = parent, children = {},
              }
              local siblings = parent and parent.children or roots
              siblings[#siblings + 1] = node
              stack[#stack + 1] = node
            end
          end
          return roots
        end

        local function containing(nodes, line)
          local low, high = 1, #nodes
          while low <= high do
            local mid = math.floor((low + high) / 2)
            local node = nodes[mid]
            if line < node.start_line then high = mid - 1
            elseif line > node.end_line then low = mid + 1
            else return node end
          end
        end

        local function selected_fold(roots, line)
          local closed, closed_end = vim.fn.foldclosed(line), vim.fn.foldclosedend(line)
          local node, selected = containing(roots, line), nil
          while node do
            if node.end_line - node.start_line + 1 > vim.wo.foldminlines then
              selected = node
              if closed ~= -1 and node.start_line == closed and node.end_line == closed_end then break end
            end
            node = containing(node.children, line)
          end
          return selected
        end

        local function current_fold()
          return selected_fold(fold_tree(), vim.api.nvim_win_get_cursor(0)[1])
        end

        local indent = require("ibl.indent")
        local hooks = require("ibl.hooks")

        -- Project the fold onto an existing guide in its first indented body
        -- line. A same-indent fold (e.g. a docstring) reuses the preceding guide.
        -- Whitespace only places the marker; it never determines the fold range.
        local function guide_column(node)
          local lines = vim.api.nvim_buf_get_lines(0, node.start_line - 1, node.end_line, false)
          local prefix = lines[1]:match("^%s*")
          local options = {
            shiftwidth = vim.bo.shiftwidth, tabstop = vim.bo.tabstop,
            vartabstop = vim.bo.vartabstop, smart_indent_cap = true,
          }
          local guides, state = indent.get(prefix, options, false)
          for i = 2, #lines do
            local body_prefix = lines[i]:match("^%s*")
            if #body_prefix > 0 and lines[i]:find("%S") then
              guides = indent.get(body_prefix, options, false, state)
              break
            end
          end
          local column
          local anchor = vim.fn.indent(node.start_line)
          for i, space in ipairs(guides) do
            if i - 1 <= anchor and indent.is_indent(space) then column = i - 1 end
          end
          return column
        end

        -- One lookup per indent-blankline refresh, including refreshes after
        -- asynchronous fold updates that do not change the buffer's text.
        local draw_state
        hooks.register(hooks.type.ACTIVE, function()
          draw_state = nil
          return true
        end)
        hooks.register(hooks.type.VIRTUAL_TEXT, function(_, buf, row, chunks)
          if buf ~= vim.api.nvim_get_current_buf() or vim.bo.buftype ~= "" then return chunks end
          if not draw_state then
            local selected = current_fold()
            draw_state = {
              selected = selected,
              column = selected and guide_column(selected),
              leftcol = vim.fn.winsaveview().leftcol,
            }
          end
          local selected = draw_state.selected
          if not selected or not draw_state.column
            or row + 1 < selected.start_line or row + 1 > selected.end_line then return chunks end
          local column = draw_state.leftcol
          for _, chunk in ipairs(chunks) do
            if column == draw_state.column and chunk[1] == "│" then
              local groups = type(chunk[2]) == "table" and chunk[2] or { chunk[2] }
              chunk[2] = vim.list_extend(vim.deepcopy(groups), { "FoldTreeSelected" })
              break
            end
            column = column + vim.fn.strdisplaywidth(chunk[1])
          end
          return chunks
        end)

        -- Parent/children links also provide the structure for fold navigation.
        _G.loris_fold_tree = { get = fold_tree, current = current_fold }
      '';

      opts = {
        foldmethod = "expr";
        foldexpr = "v:lua.vim.treesitter.foldexpr()";
        foldenable = true;
        foldcolumn = "0";
        statuscolumn = "";
        foldtext = "getline(v:foldstart) . '  …  ' . (v:foldend - v:foldstart + 1) . ' lines'";
        fillchars.fold = " ";
        # Detect folds without collapsing files when they are opened.
        foldlevel = 99;
        foldlevelstart = 99;
      };

      keymaps = [
        {
          mode = "n";
          key = "<leader>z";
          action = "<cmd>normal! za<cr><cmd>lua require('ibl').refresh(0)<cr>";
          options = {
            desc = "Toggle fold";
            silent = true;
          };
        }
      ];
    };
  };
}

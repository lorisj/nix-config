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
        local expression = 'v:lua.loris_fold_tree.expr()'
        local cache, attached, pending = {}, {}, {}
        local tracked, selections, fold_restore = {}, {}, {}
        local body_query

        local function refresh_later(buf)
          if pending[buf] then return end
          pending[buf] = true
          vim.schedule(function()
            pending[buf], cache[buf] = nil, nil
            if not vim.api.nvim_buf_is_loaded(buf) then return end
            for _, win in ipairs(vim.fn.win_findbuf(buf)) do
              if vim.wo[win].foldmethod == 'expr' and vim.wo[win].foldexpr == expression then
                vim.api.nvim_win_call(win, function()
                  -- Re-evaluate the whole buffer: changing one statement can change a
                  -- group boundary outside Tree-sitter's edited range.
                  vim.wo.foldexpr = expression
                  require('ibl').debounced_refresh(buf)
                end)
              end
            end
          end)
        end

        local function track_buffer(buf)
          if tracked[buf] then return end
          tracked[buf] = true
          vim.api.nvim_buf_attach(buf, false, {
            on_lines = function() cache[buf] = nil; refresh_later(buf) end,
            on_reload = function() cache[buf] = nil; refresh_later(buf) end,
            on_detach = function() cache[buf], tracked[buf] = nil, nil end,
          })
        end

        local function range(node)
          local first, _, last, col = node:range()
          return first + 1, last + (col > 0 and 1 or 0)
        end

        -- Copy syntax facts while building the tree. Consumers never need to
        -- query the parser or keep TSNodes alive across edits.
        local function source_metadata(node, language, buf)
          local first, last = range(node)
          local definition = node:field('definition')[1] or node
          local name = definition:field('name')[1]
          return {
            type = node:type(), language = language,
            start_line = first, end_line = last,
            name = name and vim.treesitter.get_node_text(name, buf) or nil,
            is_definition = definition:type():match('_definition$') ~= nil,
          }
        end

        -- Use the installed @fold queries, including captures spanning several
        -- sibling nodes. Convert them with the same boundary rules as Neovim's
        -- Tree-sitter foldexpr; then add statement groups before one fold update.
        local function syntax_levels(buf, count)
          local levels, sources, definitions = {}, {}, {}
          for line = 1, count do levels[line] = '0' end
          local ok, parser = pcall(vim.treesitter.get_parser, buf)
          if not ok or not parser then return levels, nil, sources, definitions end
          if attached[buf] ~= parser then
            attached[buf] = parser
            parser:register_cbs({
              on_changedtree = function() cache[buf] = nil; refresh_later(buf) end,
              on_detach = function() cache[buf], attached[buf] = nil, nil end,
            })
          end
          if not parser:parse() then return levels, nil, sources, definitions end
          local enters, leaves, previous_first, previous_last = {}, {}, nil, nil
          parser:for_each_tree(function(tree, language)
            local query = vim.treesitter.query.get(language:lang(), 'folds')
            if not query then return end
            for _, match, metadata in query:iter_matches(tree:root(), buf, 0, count) do
              for id, nodes in pairs(match) do
                if query.captures[id] == 'fold' then
                  local first = vim.treesitter.get_range(nodes[1], buf, metadata[id])[1] + 1
                  local last_range = vim.treesitter.get_range(nodes[#nodes], buf, metadata[id])
                  local last = last_range[4] + (last_range[5] > 0 and 1 or 0)
                  -- Single-line statements belong to runs; inline calls/strings
                  -- must not become structural boundaries when foldminlines is 0.
                  if last - first + 1 > math.max(1, vim.wo.foldminlines)
                    and not (first == previous_first and last == previous_last) then
                    enters[first] = (enters[first] or 0) + 1
                    leaves[last] = (leaves[last] or 0) + 1
                    previous_first, previous_last = first, last
                    local key = first .. ':' .. last
                    sources[key] = sources[key] or {}
                    for _, captured in ipairs(nodes) do
                      table.insert(sources[key], source_metadata(captured, language:lang(), buf))
                      -- Native line folding can combine a decorator's call
                      -- with its definition, although the wrapper is not @fold.
                      local parent = captured:parent()
                      if parent and parent:type() == 'decorated_definition' then
                        local definition = source_metadata(parent, language:lang(), buf)
                        definitions[definition.start_line .. ':' .. definition.end_line] = { definition }
                      end
                    end
                  end
                end
              end
            end
          end)
          local depth, leave_previous = 0, 0
          for line = 1, count do
            local enter, leave = enters[line] or 0, leaves[line] or 0
            depth = depth - leave_previous + enter
            local starts = enter > 0
            if starts and leave > 0 then depth = depth - leave; leave = 0 end
            levels[line] = (starts and depth <= vim.wo.foldnestmax and '>' or "")
              .. math.min(depth, vim.wo.foldnestmax)
            leave_previous = leave
          end
          return levels, parser, sources, definitions
        end

        local function add_statement_groups(roots, owner, levels, buf, parser)
          if vim.bo[buf].filetype ~= 'python' or not parser then return end
          local trees = parser:trees()
          if not trees[1] then return end
          body_query = body_query or vim.treesitter.query.parse('python', '(block) @body')
          local additions = {}
          for _, body in body_query:iter_captures(trees[1]:root(), buf) do
            local group
            local function finish()
              if group then additions[#additions + 1] = group end
              group = nil
            end
            for statement in body:iter_children() do
              if statement:named() and statement:type() ~= 'comment' then
                local first, last = range(statement)
                local parent = owner[first]
                local eligible = parent and parent.depth < vim.wo.foldnestmax
                  and last <= parent.end_line
                  and not (first <= parent.start_line and last >= parent.end_line)
                -- Nested bodies are visited separately. Their enclosing clauses
                -- (for example, match cases) must not create overlapping runs.
                if eligible then
                  for child in statement:iter_children() do
                    if child:type() == 'block' then eligible = false; break end
                  end
                end
                if eligible then
                  for _, child in ipairs(parent.children) do
                    if child.start_line > last then break end
                    if child.end_line >= first then eligible = false; break end
                  end
                end
                if not eligible then
                  finish()
                else
                  if group and group.parent ~= parent then finish() end
                  if not group then
                    group = { start_line = first, end_line = last, depth = parent.depth + 1,
                      parent = parent, children = {}, kind = 'statements',
                      metadata = { type = 'statement_run', language = 'python', sources = {} } }
                  end
                  group.end_line = last
                  table.insert(group.metadata.sources, source_metadata(statement, 'python', buf))
                end
              end
            end
            finish()
          end
          for _, group in ipairs(additions) do
            table.insert(group.parent.children, group)
            -- A one-line run remains a selectable leaf without adding a native
            -- fold that can merge into the following same-start nested folds.
            if group.end_line > group.start_line then
              -- Starting both a parent and its run on one line needs an explicit
              -- end for the preceding sibling, or foldexpr can merge them.
              local previous = group.start_line - 1
              if group.start_line == group.parent.start_line and previous > 0
                and (tonumber(levels[previous]:match('%d+')) or 0) >= group.parent.depth then
                levels[previous] = '<' .. group.parent.depth
              end
              for line = group.start_line, group.end_line do levels[line] = tostring(group.depth) end
              levels[group.start_line] = '>' .. group.depth
              levels[group.end_line] = '<' .. group.depth
            end
          end
        end

        local function state()
          local buf = vim.api.nvim_get_current_buf()
          track_buffer(buf)
          local key = table.concat({vim.api.nvim_buf_get_changedtick(buf), vim.wo.foldminlines,
            vim.wo.foldnestmax, vim.bo.filetype}, ':')
          if cache[buf] and cache[buf][key] then return cache[buf][key] end
          local roots, stack, owner = {}, {}, {}
          local count = vim.api.nvim_buf_line_count(buf)
          local levels, parser, sources, definitions = syntax_levels(buf, count)
          for line, value in ipairs(levels) do
            local starts = tonumber(value:match('^>(%d+)'))
            local depth = math.max(0, starts or tonumber(value) or 0)
            local keep = starts and math.max(0, math.min(depth, starts - 1)) or depth
            while #stack > keep do table.remove(stack).end_line = line - 1 end
            while #stack < depth do
              local parent = stack[#stack]
              local node = {start_line = line, end_line = count, depth = #stack + 1,
                parent = parent, children = {}, kind = 'syntax'}
              local siblings = parent and parent.children or roots
              siblings[#siblings + 1] = node
              stack[#stack + 1] = node
            end
            owner[line] = stack[#stack]
          end
          add_statement_groups(roots, owner, levels, buf, parser)
          local result = { bufnr = buf, key = key, roots = roots, nodes = {}, levels = levels }
          -- The flat index visits each parent before its children (preorder).
          local function index(nodes)
            table.sort(nodes, function(a,b) return a.start_line < b.start_line end)
            for position, node in ipairs(nodes) do
              node.index, node.id = position, #result.nodes + 1
              result.nodes[node.id] = node
              if node.kind == 'syntax' then
                -- Some native folds combine/adjust syntax ranges. Do not
                -- mislabel a signature as its entire function just because
                -- both begin on the same line.
                local key = node.start_line .. ':' .. node.end_line
                local captures = definitions[key] or sources[key] or {}
                node.metadata = { sources = captures }
                if #captures == 1 then
                  local source = captures[1]
                  node.metadata.type, node.metadata.language = source.type, source.language
                  node.metadata.name = source.name
                  node.metadata.is_definition = source.is_definition
                end
              end
              index(node.children)
            end
          end
          index(roots)
          -- Windows with different fold options keep separate variants, so
          -- switching between splits does not repeatedly rebuild either tree.
          cache[buf] = cache[buf] or {}
          cache[buf][key] = result
          -- Keep this across cursor movements. Buffer/parser callbacks and fold
          -- option changes invalidate it; redraws must not rescan the file.
          return result
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

        local function fold_tree()
          if vim.wo.foldmethod ~= 'expr' or vim.wo.foldexpr ~= expression then return {} end
          return state().roots
        end

        local function node_at(tree, line, closed, closed_end)
          local node, selected = containing(tree.roots, line), nil
          while node do
            if node.kind == 'statements' or node.end_line - node.start_line + 1 > vim.wo.foldminlines then
              selected = node
              if closed ~= -1 and node.start_line == closed and node.end_line == closed_end then break end
            end
            node = containing(node.children, line)
          end
          return selected
        end

        local function remember_selection(context, node)
          local cursor = vim.api.nvim_win_get_cursor(0)
          context.selected, context.line, context.column = node, cursor[1], cursor[2]
          context.closed = vim.fn.foldclosed(cursor[1])
          context.closed_end = vim.fn.foldclosedend(cursor[1])
          -- Remember the whole path, including selections made with ordinary
          -- cursor movement. Selecting a parent keeps its own child history.
          while node and node.parent do
            context.last_children[node.parent] = node
            node = node.parent
          end
        end

        -- Trees belong to buffers; selection belongs to a window. A query
        -- updates selection lazily, without rebuilding the cached tree.
        local function selection_state()
          local win, buf = vim.api.nvim_get_current_win(), vim.api.nvim_get_current_buf()
          if vim.wo.foldmethod ~= 'expr' or vim.wo.foldexpr ~= expression then
            selections[win] = nil
            return { winid = win, bufnr = buf }
          end
          local tree = state()
          local cursor = vim.api.nvim_win_get_cursor(win)
          local closed, closed_end = vim.fn.foldclosed(cursor[1]), vim.fn.foldclosedend(cursor[1])
          local context = selections[win]
          if not context or context.tree ~= tree then
            context = { winid = win, bufnr = buf, tree = tree, last_children = {} }
            selections[win] = context
          end
          if context.line ~= cursor[1] or context.column ~= cursor[2]
            or context.closed ~= closed or context.closed_end ~= closed_end then
            remember_selection(context, node_at(tree, cursor[1], closed, closed_end))
          end
          return context
        end

        local function current_fold()
          return selection_state().selected
        end

        local function sibling(tree, node, offset)
          if not tree or not node or tree.nodes[node.id] ~= node then return end
          local siblings = node.parent and node.parent.children or tree.roots
          return siblings[node.index + offset]
        end

        local function open_fold(context, node)
          vim.cmd(node.start_line .. 'foldopen')
          -- Restore children temporarily closed to toggle this ancestor.
          local restore = fold_restore[context.winid]
          if not restore or restore.tree ~= context.tree then return end
          local children = restore.nodes[node] or {}
          for i = #children, 1, -1 do
            local child = children[i]
            if vim.fn.foldclosed(child.start_line) == child.start_line
              and vim.fn.foldclosedend(child.start_line) == child.end_line then
              vim.cmd(child.start_line .. 'foldopen')
            end
          end
          restore.nodes[node] = nil
        end

        local function jump_to(context, target)
          if not target or target == context.selected then return end
          local text = vim.api.nvim_buf_get_lines(context.bufnr, target.start_line - 1, target.start_line, false)[1]
          vim.cmd("normal! m'")
          -- Entering a child reveals its ancestors, preserving the target's
          -- own closed state. Sibling/parent movement leaves visible folds alone.
          local ancestors, parent = {}, target.parent
          while parent do
            ancestors[#ancestors + 1] = parent
            parent = parent.parent
          end
          for i = #ancestors, 1, -1 do
            local ancestor = ancestors[i]
            if vim.fn.foldclosed(target.start_line) == ancestor.start_line
              and vim.fn.foldclosedend(target.start_line) == ancestor.end_line then
              open_fold(context, ancestor)
            end
          end
          vim.api.nvim_win_set_cursor(0, { target.start_line, #(text:match('^%s*')) })
          -- A parent and child can begin on the same line. Keep the node we
          -- navigated to selected until the cursor or fold state changes.
          remember_selection(context, target)
          require('ibl').refresh(0)
        end

        local function jump_sibling(direction)
          local context = selection_state()
          local target = context.selected
          for _ = 1, vim.v.count1 do
            local next_node = sibling(context.tree, target, direction)
            if not next_node then break end
            target = next_node
          end
          jump_to(context, target)
        end

        local function jump_skip(direction)
          local context = selection_state()
          local target = context.selected
          for _ = 1, vim.v.count1 do
            if not target then break end
            local next_node = sibling(context.tree, target, direction)
            if direction < 0 then
              -- Backward stops at the parent when there is no previous sibling.
              next_node = next_node or target.parent
            else
              -- Forward skips the entire subtree, leaving enclosing blocks as
              -- needed to reach the next node after it.
              local parent = target.parent
              while not next_node and parent do
                next_node = sibling(context.tree, parent, 1)
                parent = parent.parent
              end
            end
            if not next_node then break end
            target = next_node
          end
          jump_to(context, target)
        end

        local function jump_node(direction)
          local context = selection_state()
          if not context.selected then return end
          local nodes = context.tree.nodes
          local index = math.max(1, math.min(#nodes, context.selected.id + direction * vim.v.count1))
          jump_to(context, nodes[index])
        end

        local function jump_parent()
          local context = selection_state()
          local target = context.selected
          for _ = 1, vim.v.count1 do
            if not target or not target.parent then break end
            target = target.parent
          end
          jump_to(context, target)
        end

        local function jump_child()
          local context = selection_state()
          local target = context.selected
          for _ = 1, vim.v.count1 do
            if not target then break end
            local child = context.last_children[target] or target.children[1]
            if not child then break end
            target = child
          end
          jump_to(context, target)
        end

        local function toggle()
          local context = selection_state()
          local node = context.selected
          if not node then vim.cmd('normal! za'); return end
          if node.kind == 'statements' and node.start_line == node.end_line then return end
          local restore = fold_restore[context.winid]
          if not restore or restore.tree ~= context.tree then
            restore = { tree = context.tree, nodes = {} }
            fold_restore[context.winid] = restore
          end
          if context.closed == node.start_line and context.closed_end == node.end_line then
            open_fold(context, node)
          else
            local children = {}
            for _ = 1, vim.wo.foldnestmax do
              vim.cmd('normal! zc')
              local first = vim.fn.foldclosed(node.start_line)
              local last = vim.fn.foldclosedend(node.start_line)
              if first == node.start_line and last == node.end_line then break end
              children[#children + 1] = { start_line = first, end_line = last }
            end
            restore.nodes[node] = children
          end
          remember_selection(context, node)
          require('ibl').refresh(0)
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

        -- Shared query API (treat returned tables as read-only):
        -- state() -> { tree = { roots, nodes, levels }, selected, last_children, bufnr, winid }
        -- tree.nodes is in preorder. Nodes have parent/children, sibling index,
        -- range, kind and metadata.
        -- Node identities/IDs last for one cached tree; query again after edits.
        _G.loris_fold_tree = {
          state = selection_state,
          get = fold_tree,
          current = current_fold,
          at = function(line)
            local tree = selection_state().tree
            return tree and node_at(tree, line)
          end,
          sibling = function(node, offset)
            return sibling(selection_state().tree, node, offset)
          end,
          jump_sibling = jump_sibling,
          jump_skip = jump_skip,
          jump_node = jump_node,
          jump_parent = jump_parent,
          jump_child = jump_child,
          expr = function() return state().levels[vim.v.lnum] or '0' end,
          toggle = toggle,
        }
        vim.opt.foldexpr = expression
        local augroup = vim.api.nvim_create_augroup('LorisStatementFolds', { clear = true })
        vim.api.nvim_create_autocmd({'TextChanged', 'TextChangedI', 'FileType'}, {
          group = augroup, callback = function(args) refresh_later(args.buf) end,
        })
        vim.api.nvim_create_autocmd('OptionSet', {
          group = augroup, pattern = {'foldminlines','foldnestmax'},
          callback = function() refresh_later(vim.api.nvim_get_current_buf()) end,
        })
        vim.api.nvim_create_autocmd('BufWipeout', {
          group = augroup, callback = function(args)
            cache[args.buf], attached[args.buf] = nil, nil
            for win, context in pairs(selections) do
              if context.bufnr == args.buf then selections[win] = nil end
            end
            for win, restore in pairs(fold_restore) do
              if restore.tree.bufnr == args.buf then fold_restore[win] = nil end
            end
          end,
        })
        vim.api.nvim_create_autocmd('WinClosed', {
          group = augroup, callback = function(args)
            local win = tonumber(args.match)
            selections[win], fold_restore[win] = nil, nil
          end,
        })
        vim.api.nvim_create_autocmd({'CursorMoved', 'CursorMovedI', 'BufWinEnter'}, {
          group = augroup, callback = function()
            local win = vim.api.nvim_get_current_win()
            local context, cursor = selections[win], vim.api.nvim_win_get_cursor(win)
            if context then
              if context.bufnr ~= vim.api.nvim_get_current_buf() then
                selections[win] = nil
              elseif context.line ~= cursor[1] or context.column ~= cursor[2] then
                context.line = nil
              end
            end
          end,
        })
      '';

      opts = {
        foldmethod = "expr";
        # The Lua callback is installed below, after its definition exists.
        foldexpr = "0";
        foldenable = true;
        foldcolumn = "0";
        statuscolumn = "";
        foldtext = "getline(v:foldstart) . '  …  ' . (v:foldend - v:foldstart + 1) . (v:foldend == v:foldstart ? ' line' : ' lines')";
        fillchars.fold = " ";
        # Detect folds without collapsing files when they are opened.
        foldlevel = 99;
        foldlevelstart = 99;
      };

      keymaps = [
        {
          mode = "n";
          key = "<leader>h";
          action = "<cmd>lua loris_fold_tree.jump_skip(-1)<cr>";
          options = {
            desc = "Previous sibling or parent";
            silent = true;
          };
        }
        {
          mode = "n";
          key = "<leader>j";
          action = "<cmd>lua loris_fold_tree.jump_node(1)<cr>";
          options = {
            desc = "Next node (depth-first)";
            silent = true;
          };
        }
        {
          mode = "n";
          key = "<leader>k";
          action = "<cmd>lua loris_fold_tree.jump_node(-1)<cr>";
          options = {
            desc = "Previous node (depth-first)";
            silent = true;
          };
        }
        {
          mode = "n";
          key = "<leader>l";
          action = "<cmd>lua loris_fold_tree.jump_skip(1)<cr>";
          options = {
            desc = "Next node after subtree";
            silent = true;
          };
        }
        {
          mode = "n";
          key = "<leader>z";
          action = "<cmd>lua loris_fold_tree.toggle()<cr>";
          options = {
            desc = "Toggle fold";
            silent = true;
          };
        }
      ];
    };
  };
}

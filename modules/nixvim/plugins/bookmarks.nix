{ ... }:
{
  flake.nixvimModules.plugins.bookmarks =
    { config, ... }:
    let
      navigationPrefix = config.loris.nixvim.navigationPrefix;
    in
    {
      config = {
        extraConfigLua = ''
          local line_bookmarks = {}

          local data_file = vim.fn.stdpath("data") .. "/line-bookmarks.json"
          local sign_group = "line_bookmarks"
          local sign_name = "LineBookmark"

          vim.fn.sign_define(sign_name, {
            text = "",
            texthl = "DiagnosticSignHint",
          })

          local function cwd_key()
            return vim.loop.cwd() or vim.fn.getcwd()
          end

          local function read_store()
            if vim.fn.filereadable(data_file) == 0 then
              return {}
            end

            local ok, decoded = pcall(vim.json.decode, table.concat(vim.fn.readfile(data_file), "\n"))
            if not ok or type(decoded) ~= "table" then
              return {}
            end

            return decoded
          end

          local function write_store(store)
            vim.fn.mkdir(vim.fn.fnamemodify(data_file, ":h"), "p")
            vim.fn.writefile(vim.split(vim.json.encode(store), "\n"), data_file)
          end

          local function bookmarks()
            local store = read_store()
            local key = cwd_key()
            local items = store[key]
            if type(items) ~= "table" then
              items = {}
              store[key] = items
            end

            return store, key, items
          end

          local function current_bookmark()
            return {
              path = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":p"),
              lnum = vim.fn.line("."),
              col = vim.fn.col("."),
              text = vim.fn.getline("."),
            }
          end

          local function bookmark_label(item)
            local path = vim.fn.fnamemodify(item.path, ":.")
            return string.format("%s:%d:%d  %s", path, item.lnum, item.col, item.text or "")
          end

          local function same_location(left, right)
            return left.path == right.path and left.lnum == right.lnum
          end

          local function find_index(items, target)
            for index, item in ipairs(items) do
              if same_location(item, target) then
                return index
              end
            end
          end

          local function clamp(value, min_value, max_value)
            return math.min(math.max(value, min_value), max_value)
          end

          local function bookmark_lnum(item, bufnr)
            local line_count = vim.api.nvim_buf_line_count(bufnr)
            return clamp(tonumber(item.lnum) or 1, 1, line_count)
          end

          local function refresh_buffer(bufnr)
            if not vim.api.nvim_buf_is_valid(bufnr) then
              return
            end

            vim.fn.sign_unplace(sign_group, { buffer = bufnr })

            local path = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ":p")
            if path == "" then
              return
            end

            local _, _, items = bookmarks()
            for _, item in ipairs(items) do
              if item.path == path then
                vim.fn.sign_place(0, sign_group, sign_name, bufnr, {
                  lnum = bookmark_lnum(item, bufnr),
                  priority = 10,
                })
              end
            end
          end

          local function refresh_current_buffer()
            refresh_buffer(vim.api.nvim_get_current_buf())
          end

          local function open_bookmark(item)
            if not item or vim.fn.filereadable(item.path) == 0 then
              vim.notify("Bookmark target no longer exists", vim.log.levels.WARN)
              return
            end

            vim.cmd.edit(vim.fn.fnameescape(item.path))
            refresh_current_buffer()
            vim.api.nvim_win_set_cursor(0, { bookmark_lnum(item, 0), math.max((tonumber(item.col) or 1) - 1, 0) })
            vim.cmd("normal! zz")
          end

          function line_bookmarks.toggle()
            local item = current_bookmark()
            if item.path == "" then
              vim.notify("Cannot bookmark an unnamed buffer", vim.log.levels.WARN)
              return
            end

            local store, key, items = bookmarks()
            local index = find_index(items, item)

            if index then
              table.remove(items, index)
              vim.notify("Removed bookmark: " .. bookmark_label(item))
            else
              table.insert(items, item)
              vim.notify("Added bookmark: " .. bookmark_label(item))
            end

            store[key] = items
            write_store(store)
            refresh_current_buffer()
          end

          local function sorted_bookmarks()
            local _, _, items = bookmarks()
            local sorted = vim.deepcopy(items)
            table.sort(sorted, function(left, right)
              if left.path ~= right.path then
                return left.path < right.path
              end
              if left.lnum ~= right.lnum then
                return left.lnum < right.lnum
              end
              return false
            end)
            return sorted
          end

          local function next_relative(step)
            local items = sorted_bookmarks()
            if #items == 0 then
              vim.notify("No bookmarks set", vim.log.levels.INFO)
              return
            end

            local current = current_bookmark()
            local selected = items[1]

            if step < 0 then
              selected = items[#items]
            end

            for _, item in ipairs(items) do
              local after_current = item.path > current.path
                or (item.path == current.path and item.lnum > current.lnum)
              local before_current = item.path < current.path
                or (item.path == current.path and item.lnum < current.lnum)

              if step > 0 and after_current then
                selected = item
                break
              elseif step < 0 and before_current then
                selected = item
              end
            end

            open_bookmark(selected)
          end

          function line_bookmarks.next()
            next_relative(1)
          end

          function line_bookmarks.previous()
            next_relative(-1)
          end

          function line_bookmarks.pick()
            local pickers = require("telescope.pickers")
            local finders = require("telescope.finders")
            local previewers = require("telescope.previewers")
            local actions = require("telescope.actions")
            local action_state = require("telescope.actions.state")
            local conf = require("telescope.config").values

            local items = sorted_bookmarks()
            if #items == 0 then
              vim.notify("No bookmarks set", vim.log.levels.INFO)
              return
            end

            pickers.new({}, {
              prompt_title = "Line bookmarks",
              finder = finders.new_table({
                results = items,
                entry_maker = function(item)
                  local display = bookmark_label(item)
                  return {
                    value = item,
                    display = display,
                    ordinal = display,
                    filename = item.path,
                    lnum = item.lnum,
                    col = item.col,
                  }
                end,
              }),
              sorter = conf.generic_sorter({}),
              previewer = previewers.new_buffer_previewer({
                define_preview = function(self, entry)
                  local item = entry.value
                  if vim.fn.filereadable(item.path) == 0 then
                    vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, { "Bookmark target no longer exists" })
                    return
                  end

                  local lines = vim.fn.readfile(item.path)
                  vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, lines)
                  vim.api.nvim_buf_call(self.state.bufnr, function()
                    vim.cmd("setlocal buftype=nofile bufhidden=wipe nobuflisted noswapfile")
                    vim.cmd("doautocmd filetypedetect BufRead " .. vim.fn.fnameescape(item.path))
                  end)

                  if not vim.api.nvim_win_is_valid(self.state.winid)
                    or vim.api.nvim_win_get_buf(self.state.winid) ~= self.state.bufnr
                  then
                    return
                  end

                  local lnum = bookmark_lnum(item, self.state.bufnr)
                  vim.api.nvim_buf_add_highlight(self.state.bufnr, -1, "TelescopePreviewLine", lnum - 1, 0, -1)
                  pcall(vim.api.nvim_win_set_cursor, self.state.winid, { lnum, math.max((tonumber(item.col) or 1) - 1, 0) })
                  if vim.api.nvim_win_is_valid(self.state.winid) then
                    pcall(vim.api.nvim_win_call, self.state.winid, function()
                      vim.cmd("normal! zz")
                    end)
                  end
                end,
              }),
              attach_mappings = function(prompt_bufnr)
                actions.select_default:replace(function()
                  local selection = action_state.get_selected_entry()
                  actions.close(prompt_bufnr)
                  open_bookmark(selection and selection.value)
                end)

                return true
              end,
            }):find()
          end

          _G.line_bookmarks = line_bookmarks

          vim.api.nvim_create_autocmd({
            "BufEnter",
            "BufWritePost",
            "DirChanged",
          }, {
            group = vim.api.nvim_create_augroup("line_bookmarks", { clear = true }),
            callback = refresh_current_buffer,
          })

          refresh_current_buffer()
        '';

        keymaps = [
          {
            mode = "n";
            key = "${navigationPrefix};;";
            action = "<cmd>lua line_bookmarks.pick()<cr>";
            options = {
              desc = "Pick line bookmark";
              silent = true;
            };
          }
          {
            mode = "n";
            key = "${navigationPrefix};s";
            action = "<cmd>lua line_bookmarks.toggle()<cr>";
            options = {
              desc = "Toggle line bookmark";
              silent = true;
            };
          }
          {
            mode = "n";
            key = "${navigationPrefix};k";
            action = "<cmd>lua line_bookmarks.previous()<cr>";
            options = {
              desc = "Previous line bookmark";
              silent = true;
            };
          }
          {
            mode = "n";
            key = "${navigationPrefix};j";
            action = "<cmd>lua line_bookmarks.next()<cr>";
            options = {
              desc = "Next line bookmark";
              silent = true;
            };
          }
        ];
      };
    };
}

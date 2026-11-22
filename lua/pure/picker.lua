-- Picker: one small fuzzy list for everything that asks you to pick something,
-- such as files, text search, problems, help, the command palette, and
-- Neovim's own "pick one" menus (vim.ui.select). Two stacked panels: a prompt
-- with the title, and the list with a "matches - total" counter.
--
-- Keys while it's open: type to narrow, Up/Down to move, Enter to open,
-- Ctrl-v / Ctrl-s to open in a split right / below, Esc to close.
--
-- M.open({ title, items = list or function(done), live = function(query, done),
--          choose = function(item, how), width, height, hint_col })
-- Items are tables with `text`. With `path` (and optional `lnum`, `col`) they
-- open as files and get an icon. `live` sources re-run on each change instead
-- of being filtered; `hint_col` draws the rest of each line in a quieter color.

local M = {}
local ns = vim.api.nvim_create_namespace('pure.picker')

-- Open a file item in the window the picker was opened from.
local function open_file(item, how)
  vim.cmd[how](vim.fn.fnameescape(item.path))
  if item.lnum then
    pcall(vim.api.nvim_win_set_cursor, 0, { item.lnum, math.max((item.col or 1) - 1, 0) })
    vim.cmd('normal! zz')
  end
end

function M.open(opts)
  local origin = vim.api.nvim_get_current_win()
  local width = opts.width or math.min(100, math.floor(vim.o.columns * 0.7))
  local height = opts.height or math.min(18, math.floor(vim.o.lines * 0.5))
  local row, col = math.floor(vim.o.lines * 0.15), math.floor((vim.o.columns - width) / 2)

  -- The prompt panel carries the title; the list panel sits right under it
  -- and carries the counter. Both are solid blocks of the panel color, so they
  -- read as one card, with a row of padding between the prompt and the list.
  local prompt_buf, list_buf =
    vim.api.nvim_create_buf(false, true), vim.api.nvim_create_buf(false, true)
  local prompt_win = vim.api.nvim_open_win(prompt_buf, true, {
    relative = 'editor',
    row = row,
    col = col,
    width = width,
    height = 1,
    style = 'minimal',
    border = 'solid',
    title = { { ' ' .. opts.title .. ' ', 'FloatTitle' } },
  })
  local list_win = vim.api.nvim_open_win(list_buf, false, {
    relative = 'editor',
    row = row + 3,
    col = col,
    width = width,
    height = height,
    style = 'minimal',
    focusable = false,
    border = { '', '', '', ' ', ' ', ' ', ' ', ' ' },
  })
  vim.bo[prompt_buf].autocomplete = false -- the completion menu would cover the list
  vim.api.nvim_buf_set_extmark(prompt_buf, ns, 0, 0, {
    virt_text = { { '› ', 'PurePickerPrefix' } },
    virt_text_pos = 'inline',
    right_gravity = false,
  })

  local items, matches, current, top, loading = {}, {}, 1, 1, true
  local live_cancel, timer = nil, vim.uv.new_timer()

  local function query() return vim.api.nvim_buf_get_lines(prompt_buf, 0, 1, false)[1] or '' end

  local function render()
    if not vim.api.nvim_win_is_valid(list_win) then
      return
    end
    current = math.max(1, math.min(current, #matches))
    top = math.min(math.max(top, current - height + 1), current)
    local lines, marks = {}, {}
    for i = top, math.min(#matches, top + height - 1) do
      local match = matches[i]
      local icon, icon_hl = '', nil
      if match.item.path then
        icon, icon_hl = MiniIcons.get('file', match.item.path)
        icon = icon .. ' '
      end
      table.insert(lines, ' ' .. icon .. match.item.text)
      table.insert(marks, {
        i = i,
        icon = #icon,
        icon_hl = icon_hl,
        positions = match.positions,
        text = match.item.text,
      })
    end
    vim.api.nvim_buf_set_lines(list_buf, 0, -1, false, lines)
    vim.api.nvim_buf_clear_namespace(list_buf, ns, 0, -1)
    for row_i, mark in ipairs(marks) do
      local r, offset = row_i - 1, 1 + mark.icon
      if mark.icon_hl then
        vim.hl.range(list_buf, ns, mark.icon_hl, { r, 1 }, { r, offset })
      end
      if opts.hint_col and #mark.text > opts.hint_col then
        vim.hl.range(list_buf, ns, 'PurePickerHint', { r, offset + opts.hint_col }, { r, -1 })
      end
      for _, char in ipairs(mark.positions or {}) do
        local byte = offset + vim.str_byteindex(mark.text, 'utf-32', char)
        vim.hl.range(list_buf, ns, 'PurePickerMatch', { r, byte }, { r, byte + 1 })
      end
      if mark.i == current then
        vim.api.nvim_buf_set_extmark(
          list_buf,
          ns,
          r,
          0,
          { line_hl_group = 'PurePickerCurrent', priority = 10 }
        )
      end
    end
    local counter = loading and 'Loading'
      or ('%d - %d'):format(#matches, opts.live and #matches or #items)
    vim.api.nvim_win_set_config(
      list_win,
      { footer = { { ' ' .. counter .. ' ', 'PurePickerCounter' } }, footer_pos = 'right' }
    )
  end

  -- Static sources are fuzzy-filtered here; live sources re-run per change.
  local function filter()
    local q = query()
    current, top = 1, 1
    if opts.live then
      if live_cancel then
        live_cancel()
      end
      loading = q ~= ''
      live_cancel = opts.live(q, function(result)
        if q == query() then
          items, matches, loading =
            result, vim.tbl_map(function(item) return { item = item } end, result), false
          render()
        end
      end)
    elseif q == '' then
      matches = vim.tbl_map(function(item) return { item = item } end, items)
    else
      local texts, by_text = {}, {}
      for i, item in ipairs(items) do
        texts[i] = item.text
        by_text[item.text] = by_text[item.text] or {}
        table.insert(by_text[item.text], item)
      end
      local found, positions = unpack(vim.fn.matchfuzzypos(texts, q))
      matches = {}
      for i, text in ipairs(found) do
        table.insert(matches, { item = table.remove(by_text[text], 1), positions = positions[i] })
      end
    end
    render()
  end

  local closed = false
  local function close()
    if closed then
      return
    end
    closed = true
    timer:stop()
    timer:close()
    if live_cancel then
      live_cancel()
    end
    vim.cmd.stopinsert()
    for _, win in ipairs({ prompt_win, list_win }) do
      pcall(vim.api.nvim_win_close, win, true)
    end
    if vim.api.nvim_win_is_valid(origin) then
      vim.api.nvim_set_current_win(origin)
    end
  end

  local function cancel()
    if not closed then
      close()
      if opts.on_cancel then
        opts.on_cancel()
      end
    end
  end

  local function choose(how)
    local match = matches[current]
    if not match then
      return cancel()
    end
    close()
    vim.schedule(function()
      if opts.choose then
        opts.choose(match.item, how)
      elseif match.item.path then
        open_file(match.item, how)
      end
    end)
  end

  local function move(delta)
    current = math.max(1, math.min(current + delta, #matches))
    render()
  end

  local function map(lhs, fn) vim.keymap.set('i', lhs, fn, { buffer = prompt_buf, nowait = true }) end
  map('<Down>', function() move(1) end)
  map('<Up>', function() move(-1) end)
  map('<CR>', function() choose('edit') end)
  map('<C-v>', function() choose('vsplit') end)
  map('<C-s>', function() choose('split') end)
  map('<Esc>', cancel)

  local group = vim.api.nvim_create_augroup('pure.picker', {})
  vim.api.nvim_create_autocmd('TextChangedI', {
    group = group,
    buffer = prompt_buf,
    callback = function()
      -- Live sources wait for a short pause in typing; static ones filter at once.
      timer:stop()
      timer:start(opts.live and 120 or 0, 0, vim.schedule_wrap(filter))
    end,
  })
  vim.api.nvim_create_autocmd('WinLeave', {
    group = group,
    buffer = prompt_buf,
    once = true,
    callback = vim.schedule_wrap(cancel),
  })

  vim.cmd.startinsert()
  if type(opts.items) == 'function' then
    opts.items(function(result)
      items, loading = result, false
      if not closed then
        filter()
      end
    end)
  else
    items, loading = opts.items or {}, false
  end
  filter()
end

-- Sources --------------------------------------------------------------------

local function rg(args, done)
  local command = vim.list_extend({ 'rg', '--hidden', '--glob', '!.git' }, args)
  local process = vim.system(command, { text = true }, function(result)
    vim.schedule(function() done(vim.split(result.stdout or '', '\n', { trimempty = true })) end)
  end)
  return function() process:kill(15) end
end

function M.files()
  M.open({
    title = 'Find a file',
    items = function(done)
      rg({ '--files' }, function(paths)
        done(vim.tbl_map(function(path) return { text = path, path = path } end, paths))
      end)
    end,
  })
end

-- Open files first, most recently used first, then the file history. The
-- history alone misses files opened in this session: Neovim saves it on exit.
function M.recent()
  local seen, items = { [vim.api.nvim_buf_get_name(0)] = true }, {}
  local function add(path)
    if path ~= '' and not seen[path] and vim.fn.filereadable(path) == 1 then
      seen[path] = true
      local short = vim.fn.fnamemodify(path, ':~:.')
      table.insert(items, { text = short, path = short })
    end
  end
  local open = vim.fn.getbufinfo({ buflisted = 1 })
  table.sort(open, function(a, b) return a.lastused > b.lastused end)
  for _, buf in ipairs(open) do
    add(buf.name)
  end
  for _, path in ipairs(vim.v.oldfiles) do
    add(vim.fs.normalize(path))
  end
  M.open({ title = 'Recent files', items = items })
end

function M.search()
  M.open({
    title = 'Search text in project',
    live = function(query, done)
      if query == '' then
        return done({})
      end
      return rg(
        { '--vimgrep', '--smart-case', '--max-columns', '200', '--', query },
        function(lines)
          local items = {}
          for i, line in ipairs(lines) do
            local path, lnum, col, text = line:match('^(.-):(%d+):(%d+):(.*)$')
            if path then
              table.insert(items, {
                text = ('%s:%s  %s'):format(path, lnum, vim.trim(text)),
                path = path,
                lnum = tonumber(lnum),
                col = tonumber(col),
              })
            end
            if i == 1000 then
              break
            end
          end
          done(items)
        end
      )
    end,
  })
end

function M.problems()
  local items = {}
  for _, d in ipairs(vim.diagnostic.get(nil, { severity = { min = vim.diagnostic.severity.HINT } })) do
    local path = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(d.bufnr), ':~:.')
    local message = d.message:gsub('%s*\n%s*', ' ')
    table.insert(items, {
      text = ('%s:%d  %s'):format(path, d.lnum + 1, message),
      path = path,
      lnum = d.lnum + 1,
      col = d.col + 1,
    })
  end
  M.open({ title = 'Problems', items = items })
end

-- Every help topic, read from the help tags files of Neovim and the plugins.
function M.help()
  local items, seen = {}, {}
  for _, file in ipairs(vim.api.nvim_get_runtime_file('doc/tags', true)) do
    for _, line in ipairs(vim.fn.readfile(file)) do
      local tag = line:match('^[^\t]+')
      if tag and not seen[tag] then
        seen[tag] = true
        table.insert(items, { text = tag })
      end
    end
  end
  M.open({
    title = 'Search help',
    items = items,
    choose = function(item) vim.cmd.help(item.text) end,
  })
end

function M.git_changes()
  local items = {}
  for _, entry in ipairs(MiniDiff.export('qf', { scope = 'all' })) do
    local path = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(entry.bufnr), ':~:.')
    table.insert(items, {
      text = ('%s:%d  %s'):format(path, entry.lnum, entry.text or ''),
      path = path,
      lnum = entry.lnum,
    })
  end
  M.open({ title = 'Git changes', items = items })
end

-- vim.ui.select, so Neovim's own menus (like code actions) use the picker.
-- Extra opts (width, height, hint_col) pass through to M.open.
function M.select(choices, opts, on_choice)
  opts = opts or {}
  local format = opts.format_item or tostring
  local items = {}
  for i, choice in ipairs(choices) do
    items[i] = { text = format(choice), index = i }
  end
  local chosen = false
  M.open({
    title = opts.prompt or 'Select',
    items = items,
    width = opts.width,
    height = opts.height,
    hint_col = opts.hint_col,
    choose = function(item)
      chosen = true
      on_choice(choices[item.index], item.index)
    end,
    on_cancel = function()
      if not chosen then
        on_choice(nil, nil)
      end
    end,
  })
end

vim.ui.select = M.select

return M

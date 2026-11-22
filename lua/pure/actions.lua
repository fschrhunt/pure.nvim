-- Actions: every action the setup offers, listed once. The list maps the
-- Space keys, defines the plain-word commands (:back, :find, ...), and fills
-- the command palette (Space p), so the palette always shows everything and
-- doubles as a cheat sheet. Only everyday actions get a key or a command; the
-- rest are a palette search away. See docs/keys.md and docs/commands.md.

local function copy_path()
  local path = vim.fn.expand('%:~:.')
  require('vim.ui.clipboard.osc52').copy('+')({ path })
  vim.notify('Copied ' .. path)
end

local function browse_folder()
  local file = vim.api.nvim_buf_get_name(0)
  MiniFiles.open(vim.uv.fs_stat(file) and file or nil) -- opens on the current file
end

-- Back and forward through the places you've been (Neovim's jump list),
-- across files, like a browser's back and forward buttons. The keys are sent
-- as typed, with Neovim's own meaning: Ctrl-i is the same character as Tab,
-- which :normal can't take as an argument.
local function press(keys)
  return function() vim.api.nvim_feedkeys(vim.keycode(keys), 'n', false) end
end
local go_back, go_forward = press('<C-o>'), press('<C-i>')

-- Open files first, most recently used first, then the file history. The
-- history alone misses files opened in this session: Neovim saves it on exit.
local function recent_files()
  local seen, files = { [vim.api.nvim_buf_get_name(0)] = true }, {}
  local function add(path)
    if path ~= '' and not seen[path] and vim.fn.filereadable(path) == 1 then
      seen[path] = true
      table.insert(files, vim.fn.fnamemodify(path, ':~:.'))
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
  MiniPick.start({
    source = {
      name = 'Recent files',
      items = files,
      show = function(buf, items, query)
        MiniPick.default_show(buf, items, query, { show_icons = true })
      end,
    },
  })
end

-- Closes what you're looking at: the split when the screen is split, otherwise
-- the file (asking first if it has unsaved changes).
local function close()
  local splits = vim.tbl_filter(
    function(win) return vim.api.nvim_win_get_config(win).relative == '' end,
    vim.api.nvim_tabpage_list_wins(0)
  )
  if #splits > 1 then
    vim.cmd.close()
  else
    vim.cmd('confirm bdelete')
  end
end

local function open_terminal()
  vim.cmd('botright split | terminal')
  vim.cmd.startinsert()
end

local function undo_history()
  vim.cmd.packadd('nvim.undotree')
  vim.cmd.Undotree()
end

local function compare_files()
  vim.cmd.packadd('nvim.difftool')
  vim.api.nvim_feedkeys(':DiffTool ', 'n', false)
end

-- { name, key or false, Ex command or function, cmd = word, short = letter }.
-- Space keys are mapped here; other keys are Neovim's own and only listed.
-- `cmd` makes the action a plain-word command, like :back, and `short` a
-- one-letter form, like :b.
local actions = {
  -- Getting around
  { 'Go back', '<leader>[', go_back, cmd = 'back', short = 'b' },
  { 'Go forward', '<leader>]', go_forward, cmd = 'forward', short = 'f' },
  -- Files
  { 'Find a file', '<leader>f', MiniPick.builtin.files, cmd = 'find' },
  { 'Recent files', '<leader>r', recent_files, cmd = 'recent' },
  { 'Search text in project', '<leader>/', MiniPick.builtin.grep_live, cmd = 'search' },
  { 'Browse folder', '<leader>e', browse_folder, cmd = 'explore' },
  { 'New file', false, 'enew' },
  { 'Save', '<leader>w', 'write' },
  { 'Save all', false, 'wall' },
  { 'Close', '<leader>q', close, cmd = 'close' },
  { 'Copy file path', false, copy_path },
  -- Windows
  { 'Split right', '<leader>+', 'vsplit' },
  { 'Split below', '<leader>-', 'split' },
  { 'Open terminal', false, open_terminal },
  -- Code
  { 'Go to definition', '<C-]>', vim.lsp.buf.definition },
  { 'Show docs', 'K', vim.lsp.buf.hover },
  { 'Find references', 'grr', vim.lsp.buf.references, cmd = 'references' },
  { 'Rename symbol', 'grn', vim.lsp.buf.rename, cmd = 'rename' },
  { 'Code actions', 'gra', vim.lsp.buf.code_action, cmd = 'actions' },
  { 'File outline', 'gO', vim.lsp.buf.document_symbol, cmd = 'outline' },
  { 'Format file', false, 'Format', cmd = 'format' },
  { 'Show problems', '<leader>d', MiniExtra.pickers.diagnostic, cmd = 'problems' },
  { 'Next problem', ']d', function() vim.diagnostic.jump({ count = 1 }) end },
  { 'Comment line', 'gcc', 'normal gcc' },
  -- Git
  { 'Show git changes', false, function() MiniDiff.toggle_overlay(0) end },
  { 'List git changes', false, MiniExtra.pickers.git_hunks },
  { 'Next git change', ']h', function() MiniDiff.goto_hunk('next') end },
  -- View and history
  { 'Undo history', false, undo_history },
  { 'Compare files', false, compare_files, cmd = 'compare' },
  { 'Toggle line wrap', false, 'set wrap!' },
  { 'Toggle line numbers', false, 'set number!' },
  { 'Toggle spell check', false, 'set spell!' },
  -- Neovim
  { 'Search help', '<leader>?', MiniPick.builtin.help },
  { 'Edit config', false, 'edit $MYVIMRC', cmd = 'config' },
  { 'Update plugins', false, function() vim.pack.update() end },
  { 'Restart Neovim', false, 'restart' },
  { 'Quit Neovim', false, 'confirm qall' },
}

local function run(action)
  if type(action) == 'string' then
    vim.cmd(action)
  else
    action()
  end
end

for _, entry in ipairs(actions) do
  local name, key, action = unpack(entry)
  if key and key:find('^<leader>') then
    vim.keymap.set('n', key, function() run(action) end, { desc = name })
  end
end

-- The palette is a compact list near the top of the screen. Entries read
-- "Name   Space x   :word", with the key and command in a quieter color.
local name_width, key_width = 26, 11
local hint = vim.api.nvim_create_namespace('pure.palette')

local function key_label(key)
  if not key then
    return ''
  end
  return (key:gsub('<leader>', 'Space '):gsub('<C%-(.)>', 'Ctrl-%1'))
end

local function show_palette(buf, items, query)
  MiniPick.default_show(buf, items, query)
  vim.api.nvim_buf_clear_namespace(buf, hint, 0, -1)
  for row, line in ipairs(vim.api.nvim_buf_get_lines(buf, 0, -1, false)) do
    if #line > name_width then
      vim.hl.range(buf, hint, 'PurePaletteHint', { row - 1, name_width }, { row - 1, #line })
    end
  end
end

local function palette_window()
  local width, height = name_width + key_width + 14, math.min(#actions, 16)
  return {
    anchor = 'NW',
    width = math.min(width, vim.o.columns - 4),
    height = height,
    row = math.floor(vim.o.lines * 0.15),
    col = math.floor((vim.o.columns - width) / 2),
  }
end

local function open_palette()
  MiniPick.ui_select(actions, {
    prompt = 'Command palette',
    format_item = function(entry)
      local command = entry.cmd and (':' .. entry.cmd) or ''
      return ('%-' .. name_width .. 's%-' .. key_width .. 's%s'):format(
        entry[1],
        key_label(entry[2]),
        command
      )
    end,
  }, function(entry)
    if entry then
      run(entry[3])
    end
  end, { source = { show = show_palette }, window = { config = palette_window } })
end
vim.keymap.set('n', '<leader>p', open_palette, { desc = 'Command palette' })

-- Plain-word commands --------------------------------------------------------

-- Neovim requires user commands to start with a capital letter, so :Back is
-- the command and typing `back` (or `b`) expands to it. It only expands when
-- the word is the whole command line, so `b` elsewhere is left alone.
local function add_command(word, short, action)
  local command = word:sub(1, 1):upper() .. word:sub(2)
  if action ~= command then -- :Format already exists; only its word is added
    vim.api.nvim_create_user_command(command, function() run(action) end, {})
  end
  for _, typed in ipairs({ word, short }) do
    local expand = ([[getcmdtype() ==# ':' && getcmdline() ==# '%s' ? '%s' : '%s']]):format(
      typed,
      command,
      typed
    )
    vim.cmd.cnoreabbrev({ '<expr>', typed, expand })
  end
end

for _, entry in ipairs(actions) do
  if entry.cmd then
    add_command(entry.cmd, entry.short, entry[3])
  end
end
add_command('palette', nil, open_palette)

-- Small comforts ------------------------------------------------------------

vim.keymap.set('n', '<Esc>', '<Cmd>nohlsearch<CR><Esc>', { desc = 'Clear search highlight' })

-- Move through wrapped lines the way they look on screen.
vim.keymap.set({ 'n', 'x' }, 'j', [[v:count == 0 ? 'gj' : 'j']], { expr = true })
vim.keymap.set({ 'n', 'x' }, 'k', [[v:count == 0 ? 'gk' : 'k']], { expr = true })

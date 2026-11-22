-- Actions: every action the setup offers, listed once. The list maps the
-- Space keys and fills the command palette (Space p), so the palette always
-- shows everything and doubles as a cheat sheet. Only everyday actions get a
-- Space key; the rest are a palette search away.

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

-- { name, key or false, Ex command or function }. Space keys are mapped
-- here. Other keys are Neovim's (or a plugin's) own and are only listed.
local actions = {
  -- Getting around
  { 'Go back', '<leader>[', go_back },
  { 'Go forward', '<leader>]', go_forward },
  -- Files
  { 'Find a file', '<leader>f', MiniPick.builtin.files },
  { 'Recent files', '<leader>r', recent_files },
  { 'Search text in project', '<leader>/', MiniPick.builtin.grep_live },
  { 'Browse folder', '<leader>e', browse_folder },
  { 'New file', false, 'enew' },
  { 'Save', '<leader>w', 'write' },
  { 'Save all', false, 'wall' },
  { 'Close', '<leader>q', close },
  { 'Copy file path', false, copy_path },
  -- Windows
  { 'Split right', '<leader>+', 'vsplit' },
  { 'Split below', '<leader>-', 'split' },
  { 'Open terminal', false, open_terminal },
  -- Code
  { 'Go to definition', '<C-]>', vim.lsp.buf.definition },
  { 'Show docs', 'K', vim.lsp.buf.hover },
  { 'Find references', 'grr', vim.lsp.buf.references },
  { 'Rename symbol', 'grn', vim.lsp.buf.rename },
  { 'Code actions', 'gra', vim.lsp.buf.code_action },
  { 'File outline', 'gO', vim.lsp.buf.document_symbol },
  { 'Format file', false, 'Format' },
  { 'Show problems', '<leader>d', MiniExtra.pickers.diagnostic },
  { 'Next problem', ']d', function() vim.diagnostic.jump({ count = 1 }) end },
  { 'Comment line', 'gcc', 'normal gcc' },
  -- Git
  { 'Show git changes', false, function() MiniDiff.toggle_overlay(0) end },
  { 'List git changes', false, MiniExtra.pickers.git_hunks },
  { 'Next git change', ']h', function() MiniDiff.goto_hunk('next') end },
  -- View and history
  { 'Undo history', false, undo_history },
  { 'Compare files', false, compare_files },
  { 'Toggle line wrap', false, 'set wrap!' },
  { 'Toggle line numbers', false, 'set number!' },
  { 'Toggle spell check', false, 'set spell!' },
  -- Neovim
  { 'Search help', '<leader>?', MiniPick.builtin.help },
  { 'Edit config', false, 'edit $MYVIMRC' },
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

-- Palette entries read "Name        Space x".
local function key_label(key)
  if not key then
    return ''
  end
  return (key:gsub('<leader>', 'Space '):gsub('<C%-(.)>', 'Ctrl-%1'))
end

vim.keymap.set('n', '<leader>p', function()
  vim.ui.select(actions, {
    prompt = 'Command palette',
    format_item = function(entry) return ('%-26s%s'):format(entry[1], key_label(entry[2])) end,
  }, function(entry)
    if entry then
      run(entry[3])
    end
  end)
end, { desc = 'Command palette' })

-- Small comforts ------------------------------------------------------------

vim.keymap.set('n', '<Esc>', '<Cmd>nohlsearch<CR><Esc>', { desc = 'Clear search highlight' })

-- Move through wrapped lines the way they look on screen.
vim.keymap.set({ 'n', 'x' }, 'j', [[v:count == 0 ? 'gj' : 'j']], { expr = true })
vim.keymap.set({ 'n', 'x' }, 'k', [[v:count == 0 ? 'gk' : 'k']], { expr = true })

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
  -- Files
  { 'Find a file', '<leader>f', MiniPick.builtin.files },
  { 'Recent files', '<leader>r', MiniExtra.pickers.oldfiles },
  { 'Open files', false, MiniPick.builtin.buffers },
  { 'Search text in project', '<leader>/', MiniPick.builtin.grep_live },
  { 'Browse folder', '<leader>e', browse_folder },
  { 'New file', false, 'enew' },
  { 'Save', '<leader>w', 'write' },
  { 'Save all', false, 'wall' },
  { 'Close file', '<leader>q', 'confirm bdelete' },
  { 'Copy file path', false, copy_path },
  -- Windows
  { 'Split right', '<leader>+', 'vsplit' },
  { 'Split below', '<leader>-', 'split' },
  { 'Close window', '<leader>x', 'close' },
  { 'Open terminal', false, open_terminal },
  -- Code
  { 'Go to definition', '<C-]>', vim.lsp.buf.definition },
  { 'Show docs', 'K', vim.lsp.buf.hover },
  { 'Find references', 'grr', vim.lsp.buf.references },
  { 'Rename symbol', 'grn', vim.lsp.buf.rename },
  { 'Code actions', 'gra', vim.lsp.buf.code_action },
  { 'File outline', 'gO', vim.lsp.buf.document_symbol },
  { 'Format file', false, require('conform').format },
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

-- Forgive a held Shift in :W, :Q and friends.
for typo, command in pairs({ W = 'write', Q = 'quit', Wq = 'wq', WQ = 'wq', Qa = 'qall' }) do
  vim.api.nvim_create_user_command(typo, command .. '<bang>', { bang = true })
end

-- Actions: every action the setup offers, listed once. The list maps the
-- Space keys, defines the plain-word commands (:back, :find, ...), and fills
-- the command palette (Space p), so the palette always shows everything and
-- doubles as a cheat sheet. Only everyday actions get a key or a command; the
-- rest are a palette search away. See docs/keys.md and docs/commands.md.

local picker = require('pure.picker')
local places = require('pure.places')

local function copy_path()
  local path = vim.fn.expand('%:~:.')
  require('vim.ui.clipboard.osc52').copy('+')({ path })
  vim.notify('Copied ' .. path)
end

local function browse_folder()
  local file = vim.api.nvim_buf_get_name(0)
  MiniFiles.open(vim.uv.fs_stat(file) and file or nil) -- opens on the current file
end

-- Neovim's jump list (every big move, also within a file) stays on its own
-- Ctrl-o / Ctrl-i. The keys are sent as typed, with Neovim's own meaning:
-- Ctrl-i is the same character as Tab, which :normal can't take as an argument.
local function press(keys)
  return function() vim.api.nvim_feedkeys(vim.keycode(keys), 'n', false) end
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
  { 'Go back', '<leader>[', places.back, cmd = 'back', short = 'b' },
  { 'Go forward', '<leader>]', places.forward, cmd = 'forward', short = 'f' },
  { 'Jump back', '<C-o>', press('<C-o>') },
  { 'Jump forward', '<C-i>', press('<C-i>') },
  -- Files
  { 'Find a file', '<leader>f', picker.files, cmd = 'find' },
  { 'Recent files', '<leader>r', picker.recent, cmd = 'recent' },
  { 'Search text in project', '<leader>/', picker.search, cmd = 'search' },
  { 'Browse folder', false, browse_folder, cmd = 'explore' },
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
  { 'Install language server', false, 'Install', cmd = 'install' },
  { 'Show problems', '<leader>d', picker.problems, cmd = 'problems' },
  { 'Next problem', ']d', function() vim.diagnostic.jump({ count = 1 }) end },
  { 'Comment line', 'gcc', 'normal gcc' },
  -- Git
  { 'Show git changes', false, function() MiniDiff.toggle_overlay(0) end },
  { 'List git changes', false, picker.git_changes },
  { 'Next git change', ']h', function() MiniDiff.goto_hunk('next') end },
  -- View and history
  { 'Undo history', false, undo_history },
  { 'Compare files', false, compare_files, cmd = 'compare' },
  { 'Toggle line wrap', false, 'set wrap!' },
  { 'Toggle line numbers', false, 'set number!' },
  { 'Toggle spell check', false, 'set spell!' },
  -- Neovim
  { 'Search help', '<leader>?', picker.help },
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

-- The palette is a compact list. Entries read "Name   󱁐 x   :word", with the
-- spacebar icon for Space and the key and command in a quieter color.
local name_width, key_width = 26, 11

local function key_label(key)
  if not key then
    return ''
  end
  return (key:gsub('<leader>', '󱁐 '):gsub('<C%-(.)>', 'Ctrl-%1'))
end

-- Pads by display width: the spacebar icon is several bytes but one column.
local function pad(text, width) return text .. (' '):rep(width - vim.fn.strdisplaywidth(text)) end

local function open_palette()
  picker.select(actions, {
    prompt = 'Command palette',
    width = name_width + key_width + 14,
    height = math.min(#actions, 16),
    hint_col = name_width,
    format_item = function(entry)
      local command = entry.cmd and (':' .. entry.cmd) or ''
      return pad(entry[1], name_width) .. pad(key_label(entry[2]), key_width) .. command
    end,
  }, function(entry)
    if entry then
      run(entry[3])
    end
  end)
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

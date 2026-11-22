-- Plugins: installs the two plugins with Neovim's built-in vim.pack (versions
-- pinned in nvim-pack-lock.json) and sets up mini.nvim's icons, picker, file
-- explorer, git changes and Space-key hints. nvim-treesitter is configured in
-- pure.syntax. See docs/plugins.md.

local group = vim.api.nvim_create_augroup('pure.plugins', {})

-- nvim-treesitter's parsers must match its version, so rebuild them whenever
-- the plugin updates. Registered before vim.pack.add so it also runs on install.
vim.api.nvim_create_autocmd('PackChanged', {
  group = group,
  callback = function(ev)
    if ev.data.spec.name == 'nvim-treesitter' and ev.data.kind == 'update' then
      if not ev.data.active then
        vim.cmd.packadd('nvim-treesitter')
      end
      vim.cmd('TSUpdate')
    end
  end,
})

vim.pack.add({
  'https://github.com/nvim-mini/mini.nvim', -- icons, picker, file explorer, git changes
  { src = 'https://github.com/nvim-treesitter/nvim-treesitter', version = 'main' }, -- parsers
}, { confirm = false })

require('mini.icons').setup()
require('mini.extra').setup()

-- One centered picker for files, search, recent files and the palette. Its
-- keys are the arrows, Enter, Esc, Tab (preview), and Ctrl-v / Ctrl-s (open in
-- a split) plus the usual text editing; the rest of mini.pick's keys are off.
require('mini.pick').setup({
  mappings = {
    choose_in_tabpage = '',
    choose_marked = '',
    mark = '',
    mark_all = '',
    move_down = '',
    move_start = '',
    move_up = '',
    paste = '',
    refine = '',
    refine_marked = '',
    scroll_down = '',
    scroll_left = '',
    scroll_right = '',
    scroll_up = '',
    toggle_info = '',
  },
  window = {
    config = function()
      local height = math.floor(0.6 * vim.o.lines)
      local width = math.floor(0.6 * vim.o.columns)
      return {
        anchor = 'NW',
        height = height,
        width = width,
        row = math.floor(0.5 * (vim.o.lines - height)),
        col = math.floor(0.5 * (vim.o.columns - width)),
      }
    end,
  },
})
vim.ui.select = MiniPick.ui_select -- every "pick one" list uses the picker

-- mini.files replaces Neovim's old file explorer, netrw, so don't load it.
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Folders side by side, with a preview of the file under the cursor:
-- [ goes back a folder, ] goes forward, Enter opens the file full screen,
-- = applies edits, Esc closes, g? lists these. Its other keys are off.
require('mini.files').setup({
  mappings = {
    close = '<Esc>',
    go_in = ']',
    go_in_plus = '<CR>',
    go_out = '[',
    go_out_plus = '',
    mark_goto = '',
    mark_set = '',
    reset = '',
    reveal_cwd = '',
    trim_left = '',
    trim_right = '',
  },
  options = { permanent_delete = false }, -- deleted files go to a trash folder
  windows = { preview = true },
})

-- Size the folder columns to the screen: the current folder takes about a
-- third of it, parent folders a sixth. The preview gets the rest.
local function size_explorer()
  local windows = MiniFiles.config.windows
  windows.width_focus = math.max(40, math.floor(vim.o.columns / 3))
  windows.width_nofocus = math.max(25, math.floor(vim.o.columns / 6))
end
size_explorer()
vim.api.nvim_create_autocmd('VimResized', { group = group, callback = size_explorer })

-- Draw the explorer as full-height columns split by a single line, like
-- windows rather than boxes; the rightmost column (usually the preview)
-- stretches to the edge of the screen.
vim.api.nvim_create_autocmd('User', {
  group = group,
  pattern = 'MiniFilesWindowUpdate',
  callback = function(args)
    local win = args.data.win_id
    local windows = MiniFiles.get_explorer_state().windows
    local last = windows[#windows].win_id == win

    local config = vim.api.nvim_win_get_config(win)
    -- A title row, a blank left margin, and a divider on the right (none on the last).
    local divider = last and ' ' or '│'
    config.border = { ' ', ' ', divider, divider, divider, '', '', ' ' }
    config.row = 0
    config.height = vim.o.lines - 1
    if last then
      config.width = math.max(vim.o.columns - config.col - 2, config.width)
    end
    vim.api.nvim_win_set_config(win, config)
  end,
})

-- Changed lines get colored line numbers; ]h and [h jump between changes.
-- Its staging keys (gh, gH) and first/last jumps ([H, ]H) are off.
require('mini.diff').setup({
  mappings = { apply = '', reset = '', textobject = '', goto_first = '', goto_last = '' },
})

-- Press Space or g and pause: a small window lists the keys that can follow,
-- with their names. Only keys that exist with a description are listed (ours,
-- and Neovim's own code keys like rename and comment), not every built-in command.
require('mini.clue').setup({
  triggers = { { mode = 'n', keys = '<Leader>' }, { mode = 'n', keys = 'g' } },
  window = { delay = 300 },
})

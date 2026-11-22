-- Plugins: installs the two plugins with Neovim's built-in vim.pack (versions
-- pinned in nvim-pack-lock.json) and sets up mini.nvim's icons, picker, file
-- explorer and git changes. nvim-treesitter is configured in pure.syntax.

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

-- One centered picker for files, search, recent files and the palette.
require('mini.pick').setup({
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

-- Folders side by side, with a preview of the file under the cursor:
-- h backs out, l goes in, Enter opens the file full screen.
require('mini.files').setup({
  mappings = { go_in_plus = '<CR>' },
  options = { permanent_delete = false }, -- deleted files go to a trash folder
  windows = { preview = true, width_focus = 40, width_nofocus = 25 },
})

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
require('mini.diff').setup()

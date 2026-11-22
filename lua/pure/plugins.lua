-- Plugins: installs every plugin with Neovim's built-in vim.pack (versions
-- pinned in nvim-pack-lock.json) and sets up mini.nvim's icons, picker,
-- file explorer and git changes. Language and syntax plugins are configured
-- in pure.code and pure.syntax.

-- nvim-treesitter's parsers must match its version, so rebuild them whenever
-- the plugin updates. Registered before vim.pack.add so it also runs on install.
vim.api.nvim_create_autocmd('PackChanged', {
  group = vim.api.nvim_create_augroup('pure.plugins', {}),
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
  { src = 'https://github.com/nvim-treesitter/nvim-treesitter', version = 'main' },
  'https://github.com/neovim/nvim-lspconfig', -- ready-made language server settings
  'https://github.com/stevearc/conform.nvim', -- formatting on save
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

-- Folders side by side: h backs out, l goes in, Enter opens and closes.
require('mini.files').setup({
  mappings = { go_in_plus = '<CR>' },
  options = { permanent_delete = false }, -- deleted files go to a trash folder
  windows = { preview = true, width_preview = 50 },
})

-- Changed lines get colored line numbers; ]h and [h jump between changes.
require('mini.diff').setup()

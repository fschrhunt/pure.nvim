-- Look and behavior: editor options and the small automatic touches that
-- need no plugins.

local group = vim.api.nvim_create_augroup('pure.options', {})

-- Look ----------------------------------------------------------------------

vim.o.termguicolors = true
vim.cmd.colorscheme('pure')

-- Experimental message UI: no "Press ENTER" prompts, the command line only
-- takes space while you type, and messages appear as toasts in the corner
-- that fade after a few seconds. Delete these two lines to go back.
require('vim._core.ui2').enable({ msg = { targets = 'msg' } })
vim.o.cmdheight = 0

vim.o.number = true
vim.o.cursorline = true
vim.o.cursorlineopt = 'number' -- highlight only the current line number
vim.o.signcolumn = 'number' -- markers replace the line number, no extra column
vim.o.showmode = false -- the cursor shape already shows the mode
vim.o.ruler = false
vim.o.laststatus = 1 -- a status bar only appears once the screen is split
vim.o.statusline =
  [[ %{&buftype ==# 'terminal' ? 'Terminal' : expand('%') ==# '' ? 'New file' : expand('%:~:.')}%{&modified ? ' ●' : ''}]]
vim.o.title = true
vim.o.titlestring = [[%{&modified ? '● ' : ''}%t]] -- unsaved changes show in the tab title
vim.o.fillchars = 'eob: ,stl: ,stlnc: ,fold: ' -- no ~ past the end of the file
vim.opt.shortmess:append('Ic') -- no intro screen, no completion chatter like 'match 1 of 3'
vim.o.pumheight = 12
vim.o.scrolloff = 5
vim.o.smoothscroll = true
vim.o.linebreak = true -- wrap long lines between words
vim.o.breakindent = true
vim.o.splitright = true
vim.o.splitbelow = true

-- Behavior ------------------------------------------------------------------

vim.o.confirm = true -- ask to save instead of refusing to close
vim.o.undofile = true -- undo history survives closing the file
vim.o.ignorecase = true
vim.o.smartcase = true -- ...unless the search contains a capital letter
vim.o.expandtab = true -- filetype plugins may override these
vim.o.shiftwidth = 2
vim.o.tabstop = 2
vim.opt.jumpoptions:append('view') -- Ctrl-o restores the scroll position too

-- Typing a : command shows fuzzy suggestions; Up/Down still walk history.
vim.o.wildmode = 'noselect:lastused,full'
vim.o.wildoptions = 'pum,fuzzy'
vim.keymap.set('c', '<Up>', [[wildmenumode() ? "\<C-E>\<Up>" : "\<Up>"]], { expr = true })
vim.keymap.set('c', '<Down>', [[wildmenumode() ? "\<C-E>\<Down>" : "\<Down>"]], { expr = true })

vim.api.nvim_create_autocmd('CmdlineChanged', {
  group = group,
  pattern = ':',
  desc = 'Show suggestions while typing a command',
  callback = function() vim.fn.wildtrigger() end,
})

-- Copying sends text to the system clipboard over OSC 52, which most terminals
-- support, even over SSH. Pasting from the system is left to the terminal
-- (Cmd-V), since fewer terminals answer OSC 52 reads.
vim.o.clipboard = ''
vim.g.termfeatures = vim.tbl_extend('force', vim.g.termfeatures or {}, { osc52 = false })
local copy_to_clipboard = require('vim.ui.clipboard.osc52').copy('+')

vim.api.nvim_create_autocmd('TextYankPost', {
  group = group,
  desc = 'Flash copied text and send it to the system clipboard',
  callback = function()
    vim.hl.on_yank()
    if vim.v.event.operator == 'y' then
      local lines = vim.deepcopy(vim.v.event.regcontents)
      if vim.v.event.regtype == 'V' then
        table.insert(lines, '')
      end
      copy_to_clipboard(lines)
    end
  end,
})

vim.api.nvim_create_autocmd('BufReadPost', {
  group = group,
  desc = 'Reopen files where you left off',
  callback = function(args)
    local mark = vim.api.nvim_buf_get_mark(args.buf, '"')
    local in_file = mark[1] > 0 and mark[1] <= vim.api.nvim_buf_line_count(args.buf)
    if in_file and vim.bo[args.buf].filetype ~= 'gitcommit' then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- In a terminal, Esc twice returns to Neovim; a single Esc still reaches the
-- program running there.
vim.keymap.set('t', '<Esc><Esc>', [[<C-\><C-n>]], { desc = 'Leave the terminal' })

-- Panels: how floating windows look. Each is a solid block of the panel color
-- with padding and a blue bar down its left side, and no outline. The bar sits
-- on the terminal's own background, so a sliver of it shows between the bar
-- and the panel, as in OpenCode.
--
-- Palettes and toasts open with M.border. Every other float (hover docs, key
-- hints, problems, Neovim's messages) opens with 'winborder', which can't color
-- cells separately, so it's restyled to M.border as it appears. The completion
-- menu, which opens as you type, gets padding only.

local M = {}

local bar, pad = { '┃', 'PurePanelBar' }, { ' ', 'PurePanelPadding' }
M.border = { bar, pad, pad, pad, pad, pad, bar, bar }
-- For a panel stacked right under another one: no top edge.
M.border_below = { '', '', '', pad, pad, pad, bar, bar }

-- The same shape as plain characters, for 'winborder'. It won't take a plain
-- space, so padding cells use a non-breaking one.
local nbsp = '\194\160'
vim.o.winborder = table.concat({ '┃', nbsp, nbsp, nbsp, nbsp, nbsp, '┃', '┃' }, ',')
vim.o.pumborder = 'solid'

local function restyle(win)
  local ok, config = pcall(vim.api.nvim_win_get_config, win)
  if ok and type(config.border) == 'table' and config.border[1] == '┃' then
    vim.api.nvim_win_set_config(win, { border = M.border })
  end
end

local group = vim.api.nvim_create_augroup('pure.panels', {})

vim.api.nvim_create_autocmd('WinNew', {
  group = group,
  desc = 'Restyle floats opened with winborder',
  callback = vim.schedule_wrap(function()
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      restyle(win)
    end
  end),
})

-- Neovim's message window opens without WinNew, then gets its file type.
vim.api.nvim_create_autocmd('FileType', {
  group = group,
  pattern = 'msg',
  desc = 'Restyle the message toast',
  callback = vim.schedule_wrap(function() restyle(require('vim._core.ui2').wins.msg) end),
})

return M

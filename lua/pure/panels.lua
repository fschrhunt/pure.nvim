-- Panels: how floating windows look. Each is a solid block of the panel color
-- with padding and a blue bar down its left side, and no outline. The bar sits
-- on the terminal's own background, so it stands a little apart from the panel.
--
-- Palettes and toasts open with M.border. Every other float (hover docs, key
-- hints, problems, Neovim's messages) opens with 'winborder', which can't color
-- cells separately, so it's restyled to M.border as it appears. The completion
-- menu, which opens as you type, gets padding only. Toasts also get a close
-- button (M.closable, below).

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

-- Neovim's message window opens without WinNew, then gets its file type. It's
-- a toast too: its x, or a click anywhere on it, clears the messages.
vim.api.nvim_create_autocmd('FileType', {
  group = group,
  pattern = 'msg',
  desc = 'Restyle the message toast',
  callback = vim.schedule_wrap(function()
    local win = require('vim._core.ui2').wins.msg
    restyle(win)
    M.closable(win, function() require('vim._core.ui2.messages').msg_clear() end)
  end),
})

-- Close buttons: toasts get an x in their top-right corner, which brightens
-- while the mouse is over the toast. Clicking the x closes it; so does a click
-- anywhere on a toast that has no buttons of its own. M.closable(win, close,
-- click) registers a toast; click(pos), if given, gets the other clicks (with
-- getmousepos()). M.hovered(win) says whether the mouse is over it.
local closable, hovered = {}, nil

local function show_x(win, hot)
  pcall(vim.api.nvim_win_set_config, win, {
    title = { { 'x', hot and 'PurePanelCloseHover' or 'PurePanelClose' } },
    title_pos = 'right',
  })
end

function M.closable(win, close, click)
  closable[win] = close and { close = close, click = click } or nil
  if close then
    show_x(win, hovered == win)
  end
end

function M.hovered(win) return hovered ~= nil and hovered == win end

-- The toast under the mouse, if any, with the mouse position.
local function under_mouse()
  local pos = vim.fn.getmousepos()
  local entry = closable[pos.winid]
  if entry and vim.api.nvim_win_is_valid(pos.winid) then
    return pos, entry
  end
  closable[pos.winid] = nil
end

vim.o.mousemoveevent = true
vim.keymap.set('n', '<MouseMove>', function()
  local pos = under_mouse()
  local win = pos and pos.winid
  if win ~= hovered then
    local before = hovered
    hovered = win
    for _, w in ipairs({ before or false, win or false }) do
      if w and closable[w] and vim.api.nvim_win_is_valid(w) then
        show_x(w, w == win)
      end
    end
  end
end, { desc = 'Brighten the close button of the toast under the mouse' })

vim.keymap.set({ 'n', 'i' }, '<LeftMouse>', function()
  local pos, entry = under_mouse()
  if not pos then
    return '<LeftMouse>'
  end
  local width = vim.api.nvim_win_get_width(pos.winid)
  local on_x = pos.winrow == 1 and pos.wincol >= width and pos.wincol <= width + 2
  vim.schedule(function()
    if on_x or not entry.click then
      entry.close()
    else
      entry.click(pos)
    end
  end)
  return ''
end, { expr = true, desc = 'Click a toast: its x closes it' })

-- Language server popups (hover docs, signatures) separate sections with a
-- row of ─; draw it faint, so it reads as spacing rather than a line.
local open_preview = vim.lsp.util.open_floating_preview
vim.lsp.util.open_floating_preview = function(...)
  local buf, win = open_preview(...)
  vim.fn.matchadd('PurePanelDivider', [[^─\+$]], 10, -1, { window = win })
  return buf, win
end

return M

-- Toast: a small panel in the bottom-right corner that asks one yes-or-no
-- question with two buttons. Space y / Space n answer it while it's showing,
-- and clicking a button works too. It never takes the cursor, and it closes on
-- its own after a while, which counts as no.
--
-- M.ask({ title, message, on_yes, on_no })

local M = {}
local ns = vim.api.nvim_create_namespace('pure.toast')
local current -- the toast on screen: { win, timer, answer }

local function dismiss()
  if not current then
    return
  end
  local toast = current
  current = nil
  toast.timer:stop()
  toast.timer:close()
  pcall(vim.keymap.del, 'n', '<leader>y')
  pcall(vim.keymap.del, 'n', '<leader>n')
  pcall(vim.api.nvim_win_close, toast.win, true)
end

function M.ask(opts)
  dismiss()

  -- Lines: title, message, a blank line, then the buttons, with one space of
  -- padding on each side. Buttons name their key with the spacebar icon.
  local yes, no = ' Yes  󱁐 Y ', ' No  󱁐 N '
  local lines = { ' ' .. opts.title, ' ' .. opts.message, '', ' ' .. yes .. '  ' .. no }
  local width = 0
  for _, line in ipairs(lines) do
    width = math.max(width, vim.fn.strdisplaywidth(line) + 1)
  end

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.hl.range(buf, ns, 'PureToastTitle', { 0, 0 }, { 0, -1 })
  vim.hl.range(buf, ns, 'PureToastMessage', { 1, 0 }, { 1, -1 })
  -- Highlights are in bytes; clicks arrive in screen columns. The icon is
  -- several bytes but one column wide, so each button keeps both.
  local yes_byte, no_byte = 1, 1 + #yes + 2
  local yes_col, no_col = 1, 1 + vim.fn.strdisplaywidth(yes) + 2
  vim.hl.range(buf, ns, 'PureToastYes', { 3, yes_byte }, { 3, yes_byte + #yes })
  vim.hl.range(buf, ns, 'PureToastNo', { 3, no_byte }, { 3, no_byte + #no })

  -- Bottom-right corner, above anything else there; the border comes from
  -- 'winborder', so it has the same bar as every panel.
  local win = vim.api.nvim_open_win(buf, false, {
    relative = 'editor',
    anchor = 'SE',
    row = vim.o.lines - 1,
    col = vim.o.columns - 1,
    width = width,
    height = #lines,
    style = 'minimal',
    zindex = 60,
  })

  local function answer(said_yes)
    dismiss()
    local callback = said_yes and opts.on_yes or opts.on_no
    if callback then
      callback()
    end
  end
  current = { win = win, timer = vim.uv.new_timer() }
  current.timer:start(12000, 0, vim.schedule_wrap(function() answer(false) end))

  vim.keymap.set('n', '<leader>y', function() answer(true) end, { desc = 'Yes: ' .. opts.title })
  vim.keymap.set('n', '<leader>n', function() answer(false) end, { desc = 'No' })

  -- A click lands in the toast's window; answer by which button was under it,
  -- then hand the cursor back.
  vim.keymap.set('n', '<LeftRelease>', function()
    local mouse = vim.fn.getmousepos()
    vim.cmd.wincmd('p')
    local on_buttons, col = mouse.winid == win and mouse.line == 4, mouse.wincol
    if on_buttons and col > yes_col and col <= yes_col + vim.fn.strdisplaywidth(yes) then
      answer(true)
    elseif on_buttons and col > no_col and col <= no_col + vim.fn.strdisplaywidth(no) then
      answer(false)
    end
  end, { buffer = buf })
end

return M

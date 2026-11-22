-- Toast: a small panel in the bottom-right corner that follows one task from
-- question to result. It asks a yes-or-no question with two buttons (Space y /
-- Space n or a click answer it); it never takes the cursor and stays until
-- answered. Answering Yes turns it into progress for the task, then the
-- result, and it closes a moment later, or once the mouse leaves it. Its x
-- closes it any time (for a question, that's No), and a click anywhere on a
-- toast without buttons does too. Toasts take turns: the next one shows only
-- after the current one has closed.
--
-- M.ask({ title, message, on_yes = function(update) end, on_no })
-- M.progress(text) shows progress without a question.
-- Both hand the task an update(text, state) function; state 'done' or
-- 'failed' shows the result and closes the toast a moment later.

local M = {}
local panels = require('pure.panels')
local ns = vim.api.nvim_create_namespace('pure.toast')
-- The toast on screen: { win, buf, timer, dismiss, click }. dismiss runs for
-- its x; click, while it has buttons, gets the other clicks.
local current
local queue = {} -- functions that show the toasts waiting their turn

-- The screen row the toast's bottom edge sits on: the last row, or just above
-- Neovim's own message, which shares the corner, while one is showing.
local function bottom_row()
  local ok, ui2 = pcall(require, 'vim._core.ui2')
  local msg = ok and ui2.wins and ui2.wins.msg
  if msg and vim.api.nvim_win_is_valid(msg) then
    local config = vim.api.nvim_win_get_config(msg)
    if not config.hide then
      return vim.o.lines - 1 - vim.api.nvim_win_get_height(msg) - 2
    end
  end
  return vim.o.lines - 1
end

local function close()
  if not current then
    return
  end
  panels.closable(current.win, nil)
  pcall(vim.keymap.del, 'n', '<leader>y')
  pcall(vim.keymap.del, 'n', '<leader>n')
  pcall(vim.api.nvim_win_close, current.win, true)
  current.timer:stop()
  current.timer:close()
  current = nil
  if #queue > 0 then
    table.remove(queue, 1)()
  end
end

-- Breaks text into lines that fit a toast: at most 60 columns, less on small
-- screens, each with a space of padding in front.
local function wrap(text)
  local limit = math.min(60, vim.o.columns - 8)
  local lines, line = {}, ''
  for word in text:gmatch('%S+') do
    if line ~= '' and vim.fn.strdisplaywidth(line .. ' ' .. word) > limit then
      table.insert(lines, ' ' .. line)
      line = word
    else
      line = line == '' and word or (line .. ' ' .. word)
    end
  end
  table.insert(lines, ' ' .. line)
  return lines
end

-- Adds text to lines, wrapped, with every added line highlighted as group.
local function add(lines, marks, text, group)
  for _, line in ipairs(wrap(text)) do
    table.insert(lines, line)
    table.insert(marks, { #lines - 1, 0, -1, group })
  end
end

-- Shows lines in the toast, opening it or resizing it to fit. marks are
-- { line, from, to, group } highlights, in bytes.
local function draw(lines, marks)
  local width = 0
  for _, line in ipairs(lines) do
    width = math.max(width, vim.fn.strdisplaywidth(line) + 1)
  end
  local config = {
    relative = 'editor',
    anchor = 'SE',
    row = bottom_row(),
    col = vim.o.columns - 1,
    width = width,
    height = #lines,
    zindex = 60,
    border = panels.border,
  }
  if current then
    vim.api.nvim_win_set_config(current.win, config)
  else
    local buf = vim.api.nvim_create_buf(false, true)
    config.style = 'minimal'
    config.focusable, config.mouse = false, true -- clicks reach it without moving the cursor
    current = {
      buf = buf,
      win = vim.api.nvim_open_win(buf, false, config),
      timer = vim.uv.new_timer(),
      dismiss = close,
    }
    -- Neovim's messages come and go without an event, so look a few times a
    -- second, while a toast is up, and move out of their way.
    local toast = current
    toast.timer:start(
      250,
      250,
      vim.schedule_wrap(function()
        if current == toast and vim.api.nvim_win_is_valid(toast.win) then
          local row = bottom_row()
          if vim.api.nvim_win_get_config(toast.win).row ~= row then
            vim.api.nvim_win_set_config(
              toast.win,
              { relative = 'editor', anchor = 'SE', row = row, col = vim.o.columns - 1 }
            )
          end
        end
      end)
    )
  end
  panels.closable(current.win, current.dismiss, current.click)
  vim.api.nvim_buf_set_lines(current.buf, 0, -1, false, lines)
  vim.api.nvim_buf_clear_namespace(current.buf, ns, 0, -1)
  for _, mark in ipairs(marks) do
    vim.hl.range(current.buf, ns, mark[4], { mark[1], mark[2] }, { mark[1], mark[3] })
  end
end

-- An update(text, state) function for the toast on screen now.
local function updater()
  local toast = current
  return function(text, state)
    if current ~= toast then
      return
    end
    toast.dismiss, toast.click = close, nil -- no buttons now: a click anywhere closes it
    local lines, marks = {}, {}
    add(lines, marks, text, state == 'failed' and 'PureToastError' or 'PureToastMessage')
    draw(lines, marks)
    if state then
      -- Closes after a moment, but not while the mouse is over it.
      local function later(ms)
        vim.defer_fn(function()
          if current == toast and panels.hovered(toast.win) then
            later(1000)
          elseif current == toast then
            close()
          end
        end, ms)
      end
      later(state == 'failed' and 6000 or 2500)
    end
  end
end

local function show_question(opts)
  local yes, no = ' Yes  󱁐 Y ', ' No  󱁐 N '
  local yes_byte, no_byte = 1, 1 + #yes + 2
  local lines, marks = {}, {}
  add(lines, marks, opts.title, 'PureToastTitle')
  add(lines, marks, opts.message, 'PureToastMessage')
  vim.list_extend(lines, { '', ' ' .. yes .. '  ' .. no })
  local buttons = #lines -- the line the buttons are on
  table.insert(marks, { buttons - 1, yes_byte, yes_byte + #yes, 'PureToastYes' })
  table.insert(marks, { buttons - 1, no_byte, no_byte + #no, 'PureToastNo' })
  draw(lines, marks)
  local toast, answered = current, false

  local function answer(said_yes)
    if answered or current ~= toast then
      return
    end
    answered = true
    pcall(vim.keymap.del, 'n', '<leader>y')
    pcall(vim.keymap.del, 'n', '<leader>n')
    if said_yes and opts.on_yes then
      opts.on_yes(updater())
    else
      close()
      if opts.on_no then
        opts.on_no()
      end
    end
  end

  vim.keymap.set('n', '<leader>y', function() answer(true) end, { desc = 'Yes: ' .. opts.title })
  vim.keymap.set('n', '<leader>n', function() answer(false) end, { desc = 'No' })

  -- Answer by which button the click was on; the x says No. Clicks arrive in
  -- screen columns, counting the bar, and the spacebar icon is several bytes
  -- but one column, so buttons keep both.
  local yes_col, no_col = 1, 1 + vim.fn.strdisplaywidth(yes) + 2
  toast.dismiss = function() answer(false) end
  toast.click = function(mouse)
    local on_buttons, col = mouse.line == buttons, mouse.wincol
    if on_buttons and col > yes_col and col <= yes_col + vim.fn.strdisplaywidth(yes) then
      answer(true)
    elseif on_buttons and col > no_col and col <= no_col + vim.fn.strdisplaywidth(no) then
      answer(false)
    end
  end
  panels.closable(toast.win, toast.dismiss, toast.click)
end

function M.ask(opts)
  if current then
    table.insert(queue, function() show_question(opts) end)
  else
    show_question(opts)
  end
end

function M.progress(text)
  -- Without a screen (scripts, agents), or while another toast is up, report
  -- as plain messages instead.
  if current or #vim.api.nvim_list_uis() == 0 then
    vim.notify(text)
    return function(update_text, state)
      vim.notify(update_text, state == 'failed' and vim.log.levels.ERROR or vim.log.levels.INFO)
    end
  end
  local lines, marks = {}, {}
  add(lines, marks, text, 'PureToastMessage')
  draw(lines, marks)
  return updater()
end

return M

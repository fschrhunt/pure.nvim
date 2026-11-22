-- Places: a browser-style history of where you've been, both files and folders
-- in the file explorer. M.back and M.forward (Space [ and Space ]) move
-- through it. Going somewhere new after going back drops the forward history,
-- like a browser. Moving around inside a file isn't a new place; nvim's own
-- jump list (Ctrl-o / Ctrl-i) covers that.

local M = {}
local places, index, moving = {}, 0, false
local group = vim.api.nvim_create_augroup('pure.places', {})

local function visit(place)
  local here = places[index]
  if moving or (here and here.kind == place.kind and here.path == place.path) then
    return
  end
  for i = #places, index + 1, -1 do
    places[i] = nil
  end
  table.insert(places, place)
  if #places > 100 then
    table.remove(places, 1)
  end
  index = #places
end

local function go(to)
  local place = places[to]
  if not place then
    return
  end
  moving, index = true, to
  if MiniFiles.get_explorer_state() then
    MiniFiles.close()
  end
  if place.kind == 'file' then
    vim.cmd.edit(vim.fn.fnameescape(place.path))
    pcall(vim.api.nvim_win_set_cursor, 0, place.cursor or { 1, 0 })
  else
    MiniFiles.open(place.focus or place.path) -- reopens with the cursor where it was
  end
  moving = false
end

function M.back() go(index - 1) end
function M.forward() go(index + 1) end

vim.api.nvim_create_autocmd('BufEnter', {
  group = group,
  desc = 'Remember files you open',
  callback = function(args)
    local name = vim.api.nvim_buf_get_name(args.buf)
    if vim.bo[args.buf].buftype == '' and name ~= '' then
      visit({ kind = 'file', path = name })
    end
  end,
})

vim.api.nvim_create_autocmd('BufLeave', {
  group = group,
  desc = 'Remember where the cursor was in the file you leave',
  callback = function(args)
    local here = places[index]
    if here and here.kind == 'file' and here.path == vim.api.nvim_buf_get_name(args.buf) then
      here.cursor = vim.api.nvim_win_get_cursor(0)
    end
  end,
})

vim.api.nvim_create_autocmd('User', {
  group = group,
  pattern = 'MiniFilesExplorerOpen',
  desc = 'Remember folders you open in the explorer',
  callback = function() visit({ kind = 'folder', path = 'explorer' }) end,
})

vim.api.nvim_create_autocmd('User', {
  group = group,
  pattern = 'MiniFilesWindowUpdate',
  desc = 'Keep the folder place on the entry under the explorer cursor',
  callback = function()
    local here, entry = places[index], vim.bo.filetype == 'minifiles' and MiniFiles.get_fs_entry()
    if here and here.kind == 'folder' and entry then
      here.focus = entry.path
    end
  end,
})

return M

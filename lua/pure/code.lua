-- Code: language servers, how their problems are shown, completion while
-- typing, and formatting on save. Each server's settings live in lsp/<name>.lua;
-- the servers are installed separately (see README), and a missing one is
-- simply not started.

local group = vim.api.nvim_create_augroup('pure.code', {})

vim.lsp.enable({ 'gopls', 'ts_ls', 'astro', 'basedpyright', 'ruff', 'lua_ls', 'bashls' })

vim.diagnostic.config({
  severity_sort = true,
  virtual_text = { current_line = true }, -- the message shows on the line you're on
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = '●',
      [vim.diagnostic.severity.WARN] = '●',
      [vim.diagnostic.severity.INFO] = '●',
      [vim.diagnostic.severity.HINT] = '●',
    },
  },
})

-- Completion ----------------------------------------------------------------

-- Suggestions pop up while typing: language server first, then words from
-- open files. Accepting one also applies its imports and snippets.
vim.o.autocomplete = true
vim.o.complete = 'o,.,w'
vim.o.completeopt = 'menuone,noselect,popup,fuzzy'

vim.api.nvim_create_autocmd('LspAttach', {
  group = group,
  callback = function(args)
    local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
    if client:supports_method('textDocument/completion') then
      vim.lsp.completion.enable(true, client.id, args.buf)
    end
  end,
})

-- Tab and Shift-Tab move through suggestions (or snippet fields); Enter accepts.
vim.keymap.set({ 'i', 's' }, '<Tab>', function()
  if vim.fn.pumvisible() == 1 then
    return '<C-n>'
  elseif vim.snippet.active({ direction = 1 }) then
    return '<Cmd>lua vim.snippet.jump(1)<CR>'
  end
  return '<Tab>'
end, { expr = true })

vim.keymap.set({ 'i', 's' }, '<S-Tab>', function()
  if vim.fn.pumvisible() == 1 then
    return '<C-p>'
  elseif vim.snippet.active({ direction = -1 }) then
    return '<Cmd>lua vim.snippet.jump(-1)<CR>'
  end
  return '<S-Tab>'
end, { expr = true })

local function accept_or_newline()
  return vim.fn.complete_info({ 'selected' }).selected ~= -1 and '<C-y>' or '<CR>'
end
vim.keymap.set('i', '<CR>', accept_or_newline, { expr = true })

-- Formatting ----------------------------------------------------------------

-- Prettier formats these in projects that configure it. Everything else uses
-- its language server's formatter (gofmt for Go, ruff for Python, ...).
local prettier_filetypes = {
  astro = true,
  css = true,
  html = true,
  javascript = true,
  javascriptreact = true,
  json = true,
  jsonc = true,
  markdown = true,
  typescript = true,
  typescriptreact = true,
  yaml = true,
}
local prettier_configs = {
  '.prettierrc',
  '.prettierrc.json',
  '.prettierrc.yaml',
  '.prettierrc.yml',
  '.prettierrc.toml',
  '.prettierrc.js',
  '.prettierrc.cjs',
  '.prettierrc.mjs',
  'prettier.config.js',
  'prettier.config.cjs',
  'prettier.config.mjs',
}

-- The project's own Prettier, when the buffer is in a project that configures one.
local function project_prettier(buf)
  if not prettier_filetypes[vim.bo[buf].filetype] then
    return nil
  end
  local root = vim.fs.root(buf, prettier_configs)
  local bin = root and vim.fs.joinpath(root, 'node_modules', '.bin', 'prettier')
  if bin and vim.fn.executable(bin) == 1 then
    return bin, root
  end
end

-- Replaces only the lines that changed, so the cursor, marks and folds stay put.
local function replace_changed_lines(buf, old, new)
  local hunks = vim.text.diff(
    table.concat(old, '\n') .. '\n',
    table.concat(new, '\n') .. '\n',
    { result_type = 'indices' }
  )
  for i = #hunks, 1, -1 do
    local old_start, old_count, new_start, new_count = unpack(hunks[i])
    local first = old_count == 0 and old_start or old_start - 1
    local lines = vim.list_slice(new, new_start, new_start + new_count - 1)
    vim.api.nvim_buf_set_lines(buf, first, first + old_count, true, lines)
  end
end

local function format(buf)
  local prettier, root = project_prettier(buf)
  if prettier then
    local old = vim.api.nvim_buf_get_lines(buf, 0, -1, true)
    local result = vim
      .system({ prettier, '--stdin-filepath', vim.api.nvim_buf_get_name(buf) }, {
        cwd = root,
        stdin = table.concat(old, '\n') .. '\n',
        text = true,
      })
      :wait(3000)
    if result.code ~= 0 then
      local reason = vim.split(result.stderr or '', '\n')[1]
      vim.notify('Prettier could not format this file: ' .. reason, vim.log.levels.WARN)
      return
    end
    local new = vim.split(result.stdout, '\n')
    table.remove(new) -- the empty string after the final newline
    replace_changed_lines(buf, old, new)
  elseif #vim.lsp.get_clients({ bufnr = buf, method = 'textDocument/formatting' }) > 0 then
    vim.lsp.buf.format({ bufnr = buf, timeout_ms = 1000 })
  end
end

vim.api.nvim_create_autocmd('BufWritePre', {
  group = group,
  desc = 'Format on save',
  callback = function(args) format(args.buf) end,
})

vim.api.nvim_create_user_command('Format', function() format(0) end, { desc = 'Format the file' })

-- Code: language servers, how their problems are shown, completion while
-- typing, and formatting on save. Servers are installed separately (see
-- README); a missing one is simply not started.

vim.lsp.config('lua_ls', {
  settings = { Lua = { workspace = { library = { vim.env.VIMRUNTIME } } } }, -- knows Neovim's API
})
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
  group = vim.api.nvim_create_augroup('pure.code', {}),
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

-- Prettier in projects that configure it; otherwise the language server's
-- own formatter (gofmt for Go, ruff for Python, ...).
local prettier = { 'prettier' }

require('conform').setup({
  formatters_by_ft = {
    astro = prettier,
    css = prettier,
    html = prettier,
    javascript = prettier,
    javascriptreact = prettier,
    json = prettier,
    jsonc = prettier,
    markdown = prettier,
    typescript = prettier,
    typescriptreact = prettier,
    yaml = prettier,
  },
  formatters = { prettier = { require_cwd = true } }, -- only where a Prettier config exists
  default_format_opts = { lsp_format = 'fallback' },
  format_on_save = { timeout_ms = 1000 },
})

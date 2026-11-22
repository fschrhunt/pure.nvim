-- Code: language servers, how their problems are shown, completion while
-- typing, and formatting on save. Each language has a file in lsp/, named
-- after it, with its server's command and how to install it. Installed servers
-- start on their own; opening a file whose server is missing shows a toast,
-- and :install runs the install command. See docs/languages.md.

local group = vim.api.nvim_create_augroup('pure.code', {})

-- Language servers ----------------------------------------------------------

local languages = {}
for _, path in ipairs(vim.api.nvim_get_runtime_file('lsp/*.lua', true)) do
  local name = vim.fn.fnamemodify(path, ':t:r')
  languages[name] = vim.lsp.config[name]
end

local function installed(name) return vim.fn.executable(languages[name].cmd[1]) == 1 end

-- The language (lsp/ file name) for a file type whose server isn't installed.
local function missing_language(filetype)
  for name, config in pairs(languages) do
    if vim.tbl_contains(config.filetypes, filetype) and not installed(name) then
      return name, config
    end
  end
end

for name in pairs(languages) do
  if installed(name) then
    vim.lsp.enable(name)
  end
end

local suggested = {}
vim.api.nvim_create_autocmd('FileType', {
  group = group,
  desc = 'Suggest installing a missing language server, once per language',
  callback = function(args)
    local name, config = missing_language(args.match)
    if name and not suggested[name] then
      suggested[name] = true
      local label = name:sub(1, 1):upper() .. name:sub(2)
      vim.notify(
        ('%s needs %s for errors and completion. Run :install to add it.'):format(
          label,
          config.cmd[1]
        )
      )
    end
  end,
})

vim.api.nvim_create_user_command('Install', function()
  local name, config = missing_language(vim.bo.filetype)
  if not name then
    return vim.notify('Nothing to install for this file.')
  end
  local server = config.cmd[1]
  vim.notify(('Installing %s: %s'):format(server, config.install))
  vim.system(
    { 'sh', '-c', config.install },
    { text = true },
    vim.schedule_wrap(function(result)
      if result.code ~= 0 or not installed(name) then
        local output =
          vim.split(vim.trim(result.stderr ~= '' and result.stderr or result.stdout), '\n')
        return vim.notify(
          ('Could not install %s: %s'):format(server, output[#output]),
          vim.log.levels.ERROR
        )
      end
      vim.lsp.enable(name)
      vim.notify(server .. ' is installed.')
    end)
  )
end, { desc = "Install the language server for this file's language" })

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

-- Prettier formats these in projects that configure it, and ruff formats
-- Python. Everything else uses its language server's formatter (gofmt for Go).
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

-- A command-line formatter for the buffer, if one applies: the project's own
-- Prettier where the project configures one, or ruff for Python when it's
-- installed. Returns the tool's name, its command, and where to run it.
local function command_line_formatter(buf)
  local filetype, file = vim.bo[buf].filetype, vim.api.nvim_buf_get_name(buf)
  if prettier_filetypes[filetype] then
    local root = vim.fs.root(buf, prettier_configs)
    local bin = root and vim.fs.joinpath(root, 'node_modules', '.bin', 'prettier')
    if bin and vim.fn.executable(bin) == 1 then
      return 'Prettier', { bin, '--stdin-filepath', file }, root
    end
  elseif filetype == 'python' and vim.fn.executable('ruff') == 1 then
    return 'ruff', { 'ruff', 'format', '--stdin-filename', file, '-' }, vim.fs.root(buf, '.git')
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
  local tool, command, cwd = command_line_formatter(buf)
  if tool then
    local old = vim.api.nvim_buf_get_lines(buf, 0, -1, true)
    local result = vim
      .system(command, { cwd = cwd, stdin = table.concat(old, '\n') .. '\n', text = true })
      :wait(3000)
    if result.code ~= 0 then
      local reason = vim.split(result.stderr or '', '\n')[1]
      vim.notify(('%s could not format this file: %s'):format(tool, reason), vim.log.levels.WARN)
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

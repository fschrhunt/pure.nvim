-- Astro: @astrojs/language-server.
--
-- The server needs a TypeScript library: the project's own when it has one,
-- otherwise the one behind the global `tsc`.
local function typescript_lib(root)
  local lib = root and vim.fs.joinpath(root, 'node_modules', 'typescript', 'lib')
  if lib and vim.uv.fs_stat(lib) then
    return lib
  end
  local tsc = vim.uv.fs_realpath(vim.fn.exepath('tsc'))
  return tsc and vim.fs.joinpath(vim.fs.dirname(vim.fs.dirname(tsc)), 'lib')
end

return {
  cmd = { 'astro-ls', '--stdio' },
  filetypes = { 'astro' },
  root_markers = { 'package.json', 'tsconfig.json', '.git' },
  install = { npm = { '@astrojs/language-server', 'typescript' }, bin = 'astro-ls' },
  before_init = function(params, config)
    params.initializationOptions = { typescript = { tsdk = typescript_lib(config.root_dir) } }
  end,
}

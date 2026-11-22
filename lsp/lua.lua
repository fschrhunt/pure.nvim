-- Lua: lua-language-server. Knows Neovim's API, so editing this config gets
-- completion and docs.
return {
  cmd = { 'lua-language-server' },
  filetypes = { 'lua' },
  root_markers = { { '.luarc.json', '.luarc.jsonc' }, { '.stylua.toml', 'stylua.toml' }, '.git' },
  settings = {
    Lua = {
      runtime = { version = 'LuaJIT' },
      workspace = { library = { vim.env.VIMRUNTIME } },
    },
  },
  install = {
    github = 'LuaLS/lua-language-server',
    files = {
      ['mac-arm64'] = 'lua-language-server-{version}-darwin-arm64.tar.gz',
      ['mac-x64'] = 'lua-language-server-{version}-darwin-x64.tar.gz',
      ['linux-arm64'] = 'lua-language-server-{version}-linux-arm64.tar.gz',
      ['linux-x64'] = 'lua-language-server-{version}-linux-x64.tar.gz',
    },
    bin = 'bin/lua-language-server',
  },
}

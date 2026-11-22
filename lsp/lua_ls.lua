-- Lua: lua-language-server (brew install lua-language-server). Knows
-- Neovim's API, so editing this config gets completion and docs.
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
}

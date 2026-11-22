-- TOML: taplo, from npm, which checks the package against the registry.
return {
  cmd = { 'taplo', 'lsp', 'stdio' },
  filetypes = { 'toml' },
  root_markers = { '.taplo.toml', 'taplo.toml', '.git' },
  install = { npm = { '@taplo/cli' }, bin = 'taplo' },
}

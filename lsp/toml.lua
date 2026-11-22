-- TOML: taplo.
return {
  cmd = { 'taplo', 'lsp', 'stdio' },
  filetypes = { 'toml' },
  root_markers = { '.taplo.toml', 'taplo.toml', '.git' },
  install = {
    github = 'tamasfe/taplo',
    files = {
      ['mac-arm64'] = 'taplo-darwin-aarch64.gz',
      ['mac-x64'] = 'taplo-darwin-x86_64.gz',
      ['linux-arm64'] = 'taplo-linux-aarch64.gz',
      ['linux-x64'] = 'taplo-linux-x86_64.gz',
    },
  },
}

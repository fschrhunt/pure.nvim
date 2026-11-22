-- JSON: vscode-json-language-server.
return {
  cmd = { 'vscode-json-language-server', '--stdio' },
  filetypes = { 'json', 'jsonc' },
  root_markers = { '.git' },
  init_options = { provideFormatter = true },
  install = { npm = { 'vscode-langservers-extracted' } },
}

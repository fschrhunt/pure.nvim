-- HTML: vscode-html-language-server.
return {
  cmd = { 'vscode-html-language-server', '--stdio' },
  filetypes = { 'html' },
  root_markers = { 'package.json', '.git' },
  init_options = { provideFormatter = true },
  install = 'brew install vscode-langservers-extracted',
}

-- CSS, SCSS and Less: vscode-css-language-server.
return {
  cmd = { 'vscode-css-language-server', '--stdio' },
  filetypes = { 'css', 'scss', 'less' },
  root_markers = { 'package.json', '.git' },
  init_options = { provideFormatter = true },
  install = { npm = { 'vscode-langservers-extracted' } },
}

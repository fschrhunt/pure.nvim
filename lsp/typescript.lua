-- TypeScript and JavaScript: typescript-language-server.
return {
  cmd = { 'typescript-language-server', '--stdio' },
  filetypes = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' },
  root_markers = { { 'package-lock.json', 'yarn.lock', 'pnpm-lock.yaml', 'bun.lock' }, '.git' },
  init_options = { hostInfo = 'neovim' },
  install = { npm = { 'typescript-language-server', 'typescript' } },
}

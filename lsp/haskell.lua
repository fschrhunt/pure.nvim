-- Haskell: haskell-language-server.
return {
  cmd = { 'haskell-language-server-wrapper', '--lsp' },
  filetypes = { 'haskell', 'lhaskell' },
  root_markers = { 'stack.yaml', 'cabal.project', 'package.yaml', '.git' },
  install = 'brew install haskell-language-server',
}

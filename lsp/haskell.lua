-- Haskell: haskell-language-server, installed with ghcup so it matches your GHC.
return {
  cmd = { 'haskell-language-server-wrapper', '--lsp' },
  filetypes = { 'haskell', 'lhaskell' },
  root_markers = { 'stack.yaml', 'cabal.project', 'package.yaml', '.git' },
  install = { tool = 'ghcup install hls' },
}

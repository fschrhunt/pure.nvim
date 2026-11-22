-- Swift: sourcekit-lsp, which ships with Apple's command line tools.
return {
  cmd = { 'sourcekit-lsp' },
  filetypes = { 'swift' },
  root_markers = { 'Package.swift', '.git' },
  install = 'xcode-select --install',
}

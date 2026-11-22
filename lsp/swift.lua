-- Swift: sourcekit-lsp, which ships with the Swift toolchain.
return {
  cmd = { 'sourcekit-lsp' },
  filetypes = { 'swift' },
  root_markers = { 'Package.swift', '.git' },
  -- Comes with the Swift toolchain; there's nothing to download separately.
  install = { tool = 'xcode-select --install' },
}

-- Swift: sourcekit-lsp, which ships with the Swift toolchain: on macOS, Apple's
-- command line tools; elsewhere, Swift itself.
return {
  cmd = { 'sourcekit-lsp' },
  filetypes = { 'swift' },
  root_markers = { 'Package.swift', '.git' },
  install = vim.fn.has('mac') == 1 and { tool = 'xcode-select --install' } or { needs = 'swift' },
}

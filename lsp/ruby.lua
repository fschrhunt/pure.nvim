-- Ruby: ruby-lsp, installed with gem, the only way it ships.
return {
  cmd = { 'ruby-lsp' },
  filetypes = { 'ruby', 'eruby' },
  root_markers = { 'Gemfile', '.git' },
  install = { gem = 'ruby-lsp' },
}

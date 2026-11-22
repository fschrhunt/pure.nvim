-- Terraform: terraform-ls.
return {
  cmd = { 'terraform-ls', 'serve' },
  filetypes = { 'terraform', 'terraform-vars' },
  root_markers = { '.terraform', '.git' },
  install = 'brew install terraform-ls',
}

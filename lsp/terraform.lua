-- Terraform: terraform-ls.
return {
  cmd = { 'terraform-ls', 'serve' },
  filetypes = { 'terraform', 'terraform-vars' },
  root_markers = { '.terraform', '.git' },
  install = {
    github = 'hashicorp/terraform-ls',
    url = 'https://releases.hashicorp.com/terraform-ls/{version}/terraform-ls_{version}_{file}.zip',
    sums = 'https://releases.hashicorp.com/terraform-ls/{version}/terraform-ls_{version}_SHA256SUMS',
    files = {
      ['mac-arm64'] = 'darwin_arm64',
      ['mac-x64'] = 'darwin_amd64',
      ['linux-arm64'] = 'linux_arm64',
      ['linux-x64'] = 'linux_amd64',
    },
  },
}

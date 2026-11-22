-- PHP: intelephense.
return {
  cmd = { 'intelephense', '--stdio' },
  filetypes = { 'php' },
  root_markers = { 'composer.json', '.git' },
  install = { npm = { 'intelephense' } },
}

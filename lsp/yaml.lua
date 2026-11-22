-- YAML: yaml-language-server.
return {
  cmd = { 'yaml-language-server', '--stdio' },
  filetypes = { 'yaml', 'yaml.docker-compose', 'yaml.gitlab' },
  root_markers = { '.git' },
  install = { npm = { 'yaml-language-server' } },
}

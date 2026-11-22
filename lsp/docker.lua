-- Dockerfiles: dockerfile-language-server.
return {
  cmd = { 'docker-langserver', '--stdio' },
  filetypes = { 'dockerfile' },
  root_markers = { 'Dockerfile', '.git' },
  install = 'brew install dockerfile-language-server',
}

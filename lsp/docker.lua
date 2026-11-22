-- Dockerfiles: dockerfile-language-server.
return {
  cmd = { 'docker-langserver', '--stdio' },
  filetypes = { 'dockerfile' },
  root_markers = { 'Dockerfile', '.git' },
  install = { npm = { 'dockerfile-language-server-nodejs' } },
}

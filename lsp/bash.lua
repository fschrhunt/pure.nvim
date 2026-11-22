-- Shell scripts: bash-language-server.
return {
  cmd = { 'bash-language-server', 'start' },
  filetypes = { 'bash', 'sh' },
  root_markers = { '.git' },
  install = { npm = { 'bash-language-server' } },
}

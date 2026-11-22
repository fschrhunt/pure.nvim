-- Go: gopls, installed with the go command, the only way it ships.
return {
  cmd = { 'gopls' },
  filetypes = { 'go', 'gomod', 'gowork', 'gotmpl' },
  root_markers = { 'go.work', 'go.mod', '.git' },
  install = { go = 'golang.org/x/tools/gopls@latest' },
}

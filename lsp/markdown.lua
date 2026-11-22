-- Markdown: marksman, for links and headings across notes.
return {
  cmd = { 'marksman', 'server' },
  filetypes = { 'markdown', 'markdown.mdx' },
  root_markers = { '.marksman.toml', '.git' },
  install = {
    github = 'artempyanykh/marksman',
    files = {
      ['mac-arm64'] = 'marksman-macos',
      ['mac-x64'] = 'marksman-macos',
      ['linux-arm64'] = 'marksman-linux-arm64',
      ['linux-x64'] = 'marksman-linux-x64',
    },
  },
}

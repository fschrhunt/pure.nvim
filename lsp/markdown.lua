-- Markdown: marksman, for links and headings across notes.
return {
  cmd = { 'marksman', 'server' },
  filetypes = { 'markdown', 'markdown.mdx' },
  root_markers = { '.marksman.toml', '.git' },
  install = 'brew install marksman',
}

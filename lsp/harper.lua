-- Spelling and grammar in prose (Markdown, commit messages, plain text): harper-ls.
return {
  cmd = { 'harper-ls', '--stdio' },
  filetypes = { 'markdown', 'gitcommit', 'text' },
  root_markers = { '.git' },
  purpose = 'spelling and grammar checks',
  install = {
    github = 'Automattic/harper',
    files = {
      ['mac-arm64'] = 'harper-ls-aarch64-apple-darwin.tar.gz',
      ['mac-x64'] = 'harper-ls-x86_64-apple-darwin.tar.gz',
      ['linux-arm64'] = 'harper-ls-aarch64-unknown-linux-gnu.tar.gz',
      ['linux-x64'] = 'harper-ls-x86_64-unknown-linux-gnu.tar.gz',
    },
  },
}

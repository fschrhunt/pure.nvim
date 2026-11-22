-- Elixir: elixir-ls. Runs on the Elixir you already have.
return {
  cmd = { 'elixir-ls' },
  filetypes = { 'elixir', 'eelixir', 'heex', 'surface' },
  root_markers = { 'mix.exs', '.git' },
  install = {
    github = 'elixir-lsp/elixir-ls',
    files = {
      ['mac-arm64'] = 'elixir-ls-v{version}.zip',
      ['mac-x64'] = 'elixir-ls-v{version}.zip',
      ['linux-arm64'] = 'elixir-ls-v{version}.zip',
      ['linux-x64'] = 'elixir-ls-v{version}.zip',
    },
    bin = 'language_server.sh',
  },
}

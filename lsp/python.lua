-- Python: basedpyright for errors, types and navigation. Formatting uses ruff
-- when it's installed (see lua/pure/code.lua).
return {
  cmd = { 'basedpyright-langserver', '--stdio' },
  filetypes = { 'python' },
  root_markers = { 'pyproject.toml', 'pyrightconfig.json', 'setup.py', 'requirements.txt', '.git' },
  settings = {
    basedpyright = {
      analysis = { autoSearchPaths = true, diagnosticMode = 'openFilesOnly' },
      disableTaggedHints = true,
    },
  },
  install = 'brew install basedpyright',
}

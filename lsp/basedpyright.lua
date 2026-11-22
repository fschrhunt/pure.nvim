-- Python types and navigation: basedpyright (brew install basedpyright).
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
}

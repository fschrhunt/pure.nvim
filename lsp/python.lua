-- Python: basedpyright for errors, types and navigation. Formatting uses ruff
-- when it's installed (see lua/pure/languages.lua).
return {
  cmd = { 'basedpyright-langserver', '--stdio' },
  filetypes = { 'python' },
  root_markers = { 'pyproject.toml', 'pyrightconfig.json', 'setup.py', 'requirements.txt', '.git' },
  settings = {
    basedpyright = {
      -- standard, like most Python editors, rather than basedpyright's strict
      -- default; a project's own config (pyproject.toml) still wins.
      analysis = {
        autoSearchPaths = true,
        diagnosticMode = 'openFilesOnly',
        typeCheckingMode = 'standard',
      },
      disableTaggedHints = true,
    },
  },
  install = { npm = { 'basedpyright' }, bin = 'basedpyright-langserver' },
}

-- Svelte: svelte-language-server.
return {
  cmd = { 'svelteserver', '--stdio' },
  filetypes = { 'svelte' },
  root_markers = { 'package.json', '.git' },
  install = 'npm install -g svelte-language-server',
}

-- Svelte: svelte-language-server.
return {
  cmd = { 'svelteserver', '--stdio' },
  filetypes = { 'svelte' },
  root_markers = { 'package.json', '.git' },
  install = { npm = { 'svelte-language-server' } },
}

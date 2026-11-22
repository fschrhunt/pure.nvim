# Plugins

pure comes with two plugins:

| Plugin | What it does |
| --- | --- |
| [mini.nvim](https://github.com/nvim-mini/mini.nvim) | File icons, the file explorer, git change markers, and key hints. Only the modules pure sets up are loaded. |
| [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) | Builds language parsers and ships the syntax rules for each language. |

The rest is Neovim's own or a short file in this repository: palettes in `lua/pure/palette.lua`,
language servers in `lsp/`, formatting in `lua/pure/languages.lua`, the command palette,
completion, the clipboard, undo history, and the color scheme.

## Adding your own

Add the plugin's URL to `vim.pack.add` in `lua/pure/plugins.lua`, set it up below that, and
restart:

```lua
vim.pack.add({
  'https://github.com/nvim-mini/mini.nvim',
  { src = 'https://github.com/nvim-treesitter/nvim-treesitter', version = 'main' },
  'https://github.com/owner/your-plugin.nvim',
}, { confirm = false })

require('your-plugin').setup()
```

To give it a Space key or put it in the command palette, add a line to the list in
`lua/pure/actions.lua`.

To remove a plugin, delete it from `vim.pack.add`, restart, then delete it from disk:

```sh
nvim --headless +'lua vim.pack.del({ "plugin-name" })' +qa
```

## Versions

Neovim's built-in plugin manager, `vim.pack`, installs plugins on first launch at the exact
versions in `nvim-pack-lock.json`, so every machine runs the same code. Don't edit the lockfile
by hand.

## Updating

- In Neovim: "Update plugins" in the palette shows what changed in each plugin and asks before
  applying. Write the buffer (`:w`) to accept, or close it to cancel.
- From a shell: `./x update` applies every update and rewrites the lockfile.
- Automatically: every Monday the Dependencies workflow runs `./x update` and opens one pull
  request with a link to each plugin's changes. Merge it after CI passes.

After pulling a lockfile change, on this or any other machine, run `./x sync` to install exactly
the versions it records.

When nvim-treesitter updates, its parsers are rebuilt automatically.

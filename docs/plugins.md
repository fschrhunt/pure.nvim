# Plugins

pure.nvim uses what Neovim ships with wherever it can, and two plugins for what it can't do:

| Plugin | Gives us | Why not our own |
| --- | --- | --- |
| [mini.nvim](https://github.com/nvim-mini/mini.nvim) | File icons, the picker, the file explorer, git change markers, and Space-key hints | Each piece is a real program (the picker alone is about 4,000 lines). It's one download, and only the modules we set up are loaded. |
| [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) | Builds language parsers and ships the syntax rules for each language | The syntax rules are thousands of files maintained alongside the parsers. |

Everything else is Neovim's own or a short file in this repository: the language server settings
in `lsp/`, formatting in `lua/pure/code.lua`, the command palette, completion, the clipboard, undo
history, and the color scheme.

## Versions

Neovim's built-in plugin manager, `vim.pack`, installs the plugins on first launch at the exact
versions recorded in `nvim-pack-lock.json`, so every machine runs the same code. Don't edit the
lockfile by hand.

## Updating

- In Neovim: "Update plugins" in the palette shows what changed in each plugin and asks before
  applying. Write the buffer (`:w`) to accept, or close it to cancel.
- From a shell: `./x update` applies every update and rewrites the lockfile.
- Automatically: every Monday the Dependencies workflow runs `./x update` and opens one pull
  request with a link to each plugin's changes. Merge it after CI passes.

After pulling a lockfile change, on this or any other machine, run `./x sync` to install exactly
the versions it records.

When nvim-treesitter updates, its parsers are rebuilt automatically.

## Adding or removing a plugin

Add one only for something Neovim can't do, and prefer a small, focused plugin. Add its URL to
`vim.pack.add` in `lua/pure/plugins.lua`, set it up below that, and restart.

To remove one, delete it from `vim.pack.add`, restart, then delete it from disk:

```sh
nvim --headless +'lua vim.pack.del({ "plugin-name" })' +qa
```

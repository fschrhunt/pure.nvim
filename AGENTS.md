# Developing pure.nvim

pure.nvim is a Neovim config: clean on screen, intuitive to use, and small enough to read in one
sitting. Prefer what Neovim ships with; add a plugin only for something Neovim can't do, and
keep each change to what it needs.

## Commands

```sh
./x check     # StyLua, ShellCheck, and a headless load of the config; CI runs the same checks
./x fmt       # format Lua files
./x update    # update plugins and nvim-pack-lock.json
./x sync      # install the plugin versions in nvim-pack-lock.json
./x install   # link ~/.config/nvim to this checkout
./x hooks     # install the pre-commit hook once per clone
```

## Where things live

- `init.lua`: loads the modules below in order.
- `lua/pure/options.lua`: options, clipboard, and automatic behavior.
- `lua/pure/plugins.lua`: the two plugins for `vim.pack` and mini.nvim setup.
- `lua/pure/syntax.lua`: tree-sitter parsers, highlighting, and folding.
- `lua/pure/code.lua`: which language servers start, diagnostics, completion, and formatting.
- `lsp/`: one file per language server with its command, file types, and settings.
- `lua/pure/actions.lua`: every action, its Space key, and the command palette.
- `colors/pure.lua`: the color scheme.
- `docs/`: user docs, one file per topic: keys, languages, colors, and plugins.
- `nvim-pack-lock.json`: plugin revisions, written by `vim.pack`. Don't edit it by hand; run
  `./x update`.
- `.github/workflows/`: CI, releases, and weekly plugin updates (`dependencies.yml`).
- `.github/release/`: the release helper and the checks every release must pass.

## Conventions

- Every user-facing action goes in the `actions` list so it reaches the palette. Space keys are
  mapped from that list; don't map them elsewhere.
- Colors come only from the palette table in `colors/pure.lua`. The scheme never sets `Normal`'s
  background.
- Don't change Neovim's built-in keys; they're listed in the palette instead.
- Name autocommand groups `pure.<module>`.
- Update `docs/` and the README in the same change as the behavior they describe.

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
- `lua/pure/syntax.lua`: tree-sitter highlighting and folding, building parsers on first use.
- `lua/pure/code.lua`: starting installed servers, suggesting missing ones, diagnostics,
  completion, and formatting.
- `lsp/`: one file per language, named after it (`go.lua`, `python.lua`), with its server's
  command, file types, settings, and `install` command.
- `lua/pure/actions.lua`: every action, its Space key, and the command palette.
- `lua/pure/places.lua`: the browser-style back and forward history of files and folders.
- `lua/pure/picker.lua`: the fuzzy picker and its sources (files, recent files, text search,
  problems, help, git changes), and `vim.ui.select`.
- `colors/pure.lua`: the color scheme.
- `docs/`: user docs, one file per topic: keys, commands, languages, colors, and plugins.
- `nvim-pack-lock.json`: plugin revisions, written by `vim.pack`. Don't edit it by hand; run
  `./x update`.
- `.github/workflows/`: CI, releases, and weekly plugin updates (`dependencies.yml`).
- `.github/release/`: the release helper and the checks every release must pass.

## Conventions

- Every user-facing action goes in the `actions` list so it reaches the palette. Space keys and
  plain-word commands are made from that list; don't define them elsewhere. A command word must
  not shadow a Neovim command unless `docs/commands.md` lists it as replaced.
- Colors come only from the palette table in `colors/pure.lua`. The scheme never sets `Normal`'s
  background.
- Don't change Neovim's built-in keys; they're listed in the palette instead. The one exception is
  `j` and `k`, which move through wrapped lines the way they look.
- One key per action. Turn off plugin keys that duplicate another key or aren't documented in
  `docs/keys.md`.
- Name autocommand groups `pure.<module>`.
- Update `docs/` and the README in the same change as the behavior they describe.

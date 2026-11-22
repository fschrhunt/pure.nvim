# Developing pure.nvim

pure.nvim is a Neovim config: clean on screen, intuitive to use, and small enough to read in one
sitting. Prefer what Neovim ships with; add a plugin only for something Neovim can't do, and
keep each change to what it needs.

## Commands

```sh
./x check     # StyLua formatting and a headless load of the config; CI runs the same check
./x fmt       # format Lua files
./x install   # link ~/.config/nvim to this checkout
```

## Where things live

- `init.lua`: loads the modules below in order.
- `lua/pure/options.lua`: options, clipboard, and automatic behavior.
- `lua/pure/plugins.lua`: the plugin list for `vim.pack` and mini.nvim setup.
- `lua/pure/syntax.lua`: tree-sitter parsers, highlighting, and folding.
- `lua/pure/code.lua`: language servers, diagnostics, completion, and formatting.
- `lua/pure/actions.lua`: every action, its Space key, and the command palette.
- `colors/pure.lua`: the color scheme.
- `nvim-pack-lock.json`: plugin revisions, written by `vim.pack`. Don't edit it by hand.

## Conventions

- Every user-facing action goes in the `actions` list so it reaches the palette. Space keys are
  mapped from that list; don't map them elsewhere.
- Colors come only from the palette table in `colors/pure.lua`. The scheme never sets `Normal`'s
  background.
- Don't change Neovim's built-in keys; they're listed in the palette instead.
- Name autocommand groups `pure.<module>`.

# Developing pure.nvim

pure.nvim is a Neovim config: clean on screen, intuitive to use, and small enough to read in one
sitting. Keep each change to what it needs. Plugins are welcome when they make pure nicer to
use; list each one in `docs/plugins.md`.

## Commands

```sh
./x check     # StyLua, ShellCheck, and a headless load of the config; CI runs the same checks
./x fmt       # format Lua files
./x update    # update plugins and nvim-pack-lock.json
./x sync      # install the plugin versions in nvim-pack-lock.json
./x install   # link ~/.config/nvim to this checkout
./x servers   # check that every language server recipe still finds a checksummed download
./x hooks     # install the pre-commit hook once per clone
```

## Where things live

- `init.lua`: loads the modules below in order.
- `lua/pure/options.lua`: options, clipboard, and automatic behavior.
- `lua/pure/plugins.lua`: the plugins for `vim.pack` and their setup.
- `lua/pure/syntax.lua`: tree-sitter highlighting and folding, building parsers on first use.
- `lua/pure/languages.lua`: starting installed servers, offering missing ones, diagnostics,
  completion, and formatting.
- `lsp/`: one file per language, named after it (`go.lua`, `python.lua`), with its server's
  command, file types, settings, and `install` recipe. `harper.lua` is spelling and grammar for
  prose.
- `lua/pure/servers.lua`: installs servers from their recipes into `~/.local/share/nvim/servers`,
  and checks for updates.
- `lua/pure/actions.lua`: every action, its Space key, and the command palette.
- `lua/pure/places.lua`: the browser-style back and forward history of files and folders.
- `lua/pure/panels.lua`: how floating windows look: padding and the blue bar, no outline.
- `lua/pure/toast.lua`: yes-or-no toasts with buttons.
- `lua/pure/palette.lua`: the fuzzy palette and its sources (files, recent files, text search,
  problems, help, git changes), and `vim.ui.select`.
- `colors/pure.lua`: the color scheme.
- `docs/`: user docs, one file per topic: keys, commands, languages, colors, and plugins.
- `nvim-pack-lock.json`: plugin revisions, written by `vim.pack`. Don't edit it by hand; run
  `./x update`.
- `.github/workflows/`: CI, releases, and weekly upkeep (`dependencies.yml`): plugin updates and
  the language server recipe check.
- `.github/release/`: the release helper, the checks every release must pass, and the script
  that writes release notes into `CHANGELOG.md`. Never edit the changelog by hand; releases
  write it.

## Conventions

- Every user-facing action goes in the `actions` list so it reaches the command palette. Space
  keys and plain-word commands are made from that list; don't define them elsewhere. The
  exception is `Space y` / `Space n`, which exist only while a toast is asking. A command word
  must not shadow a Neovim command unless `docs/commands.md` lists it as replaced.
- Colors come only from the color table in `colors/pure.lua`. The scheme never sets `Normal`'s
  background.
- Don't change Neovim's built-in keys; they're listed in the command palette instead. The
  exceptions are `j` and `k`, which move through wrapped lines the way they look, and `Ctrl-h`
  `Ctrl-j` `Ctrl-k` `Ctrl-l`, which move between splits in one key.
- One key per action. Turn off plugin keys that duplicate another key or aren't documented in
  `docs/keys.md`.
- Name autocommand groups `pure.<module>`.
- Update `docs/` and the README in the same change as the behavior they describe.
- Describe pure.nvim on its own terms. Name other tools only where pure.nvim runs or installs
  them, never as a comparison or inspiration.

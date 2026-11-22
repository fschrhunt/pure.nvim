# Changelog

## Unreleased

- Add the `pure` color scheme: a soft dark palette that leaves the background to the terminal and
  colors file icons, the picker, and the file explorer to match.
- Add a command palette (`Space p`) built from one list of actions, which also maps the Space
  keys.
- Keep Space keys for everyday actions only, listed in a hint window when you press Space and
  pause; other actions are in the palette.
- Add finding files, recent files, project search, a side-by-side file explorer, and git change
  markers with mini.nvim.
- Add language servers for Go, TypeScript, Astro, Python, Lua, and shell, with completion while
  typing and formatting on save through Prettier or the language server.
- Add tree-sitter highlighting and folding for the configured languages.
- Use Neovim 0.12's experimental message UI, undo history, and file comparison.
- Configure language servers and formatting in pure.nvim's own files instead of nvim-lspconfig
  and conform.nvim, leaving mini.nvim and nvim-treesitter as the only plugins.
- Add docs for keys, languages, colors, and plugins, and `./x sync` to install the plugin
  versions recorded in the lockfile.
- Go back and forward with `Space [` and `Space ]`, and through folders in the file explorer with
  `[` and `]`. Each action has one key: the explorer's `h` and `l` and the `:W` and `:Q` typo
  commands are gone.
- Turn off duplicate and hidden plugin keys: mini.diff's `gh`, `gH`, `[H`, and `]H`, the explorer's
  extra keys, and the picker's `Ctrl-n`, `Ctrl-p`, marking, and scrolling keys. `Esc` closes the
  explorer like the picker. Recent files lists open files first, replacing "Open files".

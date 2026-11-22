# Changelog

Written by each release, newest first; the same notes are on
[GitHub Releases](https://github.com/fschrhunt/pure.nvim/releases).

## Unreleased

- Add the `pure` color scheme: a soft dark color table that leaves the background to the terminal.
  Floating panels are solid blocks with no outline and a blue bar down the left side.
- Add palettes, one fuzzy list for everything you pick from: the command palette (`Space p`),
  files, recent files (open files first), project search, problems, help, git changes, and
  Neovim's own menus. Their corner shows matches - total.
- Build the command palette, the Space keys, and plain-word commands like `:find` and `:close`
  from one list of actions, so each action has one name and at most one key. Pressing Space or `g`
  and pausing lists the keys that can follow.
- Go back and forward with `Space [` and `Space ]` through the places you've been, files and
  folders, like a browser. `Space q` closes the split, or the file when there's one window, and
  `Ctrl-h` `Ctrl-j` `Ctrl-k` `Ctrl-l` move between splits.
- Add a full-height file explorer with a preview (`:explore`): `[` and `]` move through folders,
  `Enter` opens a file, and edits apply with `=`.
- Support 25 languages, one file each in `lsp/`, named after the language, with completion
  while typing, problems underlined and on the current line, and formatting on save through
  Prettier, ruff, or the language server.
- Install language servers into pure's own folder, with no package manager: from their releases
  (every download checked against a published or pinned SHA-256), npm (with a downloaded Node.js
  if needed), or the language's own tool where that's the only way they ship. Java-based servers
  get a downloaded Java runtime when yours is missing or too old. One toast with Yes and No
  buttons asks about a file's missing servers, then shows the install's progress and result.
  `:install <language>` installs or updates one by name, and newer versions are offered weekly.
  Prose gets spelling and grammar checking. `./x servers`, also run weekly, checks that every
  recipe still finds its download.
- Highlight and fold every language nvim-treesitter supports, building each parser the first time
  its language is opened.
- Show messages as toasts in the bottom-right corner, and use Neovim 0.12's undo history and file
  comparison.
- Rely on two plugins, mini.nvim and nvim-treesitter, pinned in `nvim-pack-lock.json`; `./x
  update` updates them and `./x sync` installs the pinned versions. Plugin updates are proposed
  weekly.
- Document keys, commands, languages, colors, and plugins in `docs/`.

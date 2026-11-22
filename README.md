# pure.nvim

> A clean, quiet Neovim that's easy to make your own.

Neovim 0.12 already does most of what you need. pure.nvim sets it up nicely, adds
[mini.nvim](https://github.com/nvim-mini/mini.nvim) and
[nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter), and otherwise stays out of
your way. It's small enough to read in one sitting, so changing it is easy.

## Overview

- Nothing on screen but your code. No status bar until you split, no file tree, and no background
  color: the `pure` color scheme uses whatever background your terminal has.
- Press `Space p` for the command palette. Every action is in there, along with its key.
- Language servers install themselves. Open a file and pure offers to set up its server. It covers
  25 languages, plus spelling and grammar for prose.
- Back and forward work like a browser's, through the files and folders you've visited.

## Install

You'll need Neovim 0.12 or newer, Git, [ripgrep](https://github.com/BurntSushi/ripgrep), the
[tree-sitter CLI](https://github.com/tree-sitter/tree-sitter) with a C compiler, and a
[Nerd Font](https://www.nerdfonts.com) for file icons. Installing language servers uses `curl`,
`tar`, and `unzip`, which most systems already have. On macOS:

```sh
brew install neovim ripgrep tree-sitter
brew install --cask font-meslo-lg-nerd-font
git clone https://github.com/fschrhunt/pure.nvim ~/dev/pure.nvim
~/dev/pure.nvim/x install
```

On Linux, install the same with your package manager (Neovim 0.12 may need to come from
[its releases](https://github.com/neovim/neovim/releases) if yours is older), set your terminal
to a Nerd Font, and run the same two Git and `./x` lines.

`./x install` links `~/.config/nvim` to the checkout. It won't replace a config you already have.
On first launch, pure installs its plugins at the versions in `nvim-pack-lock.json` and builds the
tree-sitter parsers in the background.

When you open a file whose language server is missing, a toast asks whether to install it
(`Space y` / `Space n`). No package manager needed. See [languages](docs/languages.md) for the
full list.

## Keys

Press Space and pause to see what's there. Everything else is in the command palette, including
Neovim's own code keys.

| Key | Action | Key | Action |
| --- | --- | --- | --- |
| `Space p` | Command palette | `Space d` | Show problems |
| `Space f` | Find a file | `Space w` | Save |
| `Space /` | Search text in project | `Space q` | Close |
| `Space r` | Recent files | `Space -` | Split below |
| `Space ?` | Search help | `Space +` | Split right |
| `Space [` | Go back | `Space ]` | Go forward |

Open a file from the explorer (`:explore`) and `Space [` takes you back to that folder. Inside the
explorer, `[` and `]` move through folders. The everyday actions are commands too, like `:back`
(`:b`), `:forward` (`:f`), `:find`, and `:close`. [All keys](docs/keys.md) ·
[All commands](docs/commands.md)

## Make it yours

pure is a starting point, so change whatever you like:

- **Plugins:** add a URL to `vim.pack.add` in `lua/pure/plugins.lua` and set it up below. See
  [plugins](docs/plugins.md).
- **Actions:** add one line to the list in `lua/pure/actions.lua`. It shows up in the palette, and
  gets a Space key and a command if you give it them.
- **Colors:** edit the color table in `colors/pure.lua`. See [colors](docs/colors.md).

## Docs

- [Keys](docs/keys.md): every key worth knowing, in the editor, palettes, and the file explorer.
- [Commands](docs/commands.md): plain-word commands like `:back`, `:find`, and `:close`.
- [Languages](docs/languages.md): supported languages, installing servers, formatting, and adding
  a language.
- [Colors](docs/colors.md): the color table, what it colors, and how to change it.
- [Plugins](docs/plugins.md): the plugins pure uses, adding your own, and keeping them updated.

## License

[MIT](LICENSE)

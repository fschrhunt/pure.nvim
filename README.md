# pure.nvim

A clean, intuitive Neovim. Built on what Neovim 0.12 ships with, plus two plugins for what it
can't do alone: [mini.nvim](https://github.com/nvim-mini/mini.nvim) for icons, the file explorer,
git changes, and key hints, and [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter)
for syntax. The picker, language servers, and formatting are its own, in plain files.

Nothing on screen but your code. There's no status bar until you split, no file tree, and no
background color: the `pure` color scheme draws text on whatever background your terminal has.
Press `Space p` for the command palette, which lists every action with its key.

## Install

pure.nvim needs Neovim 0.12 or newer, Git, [ripgrep](https://github.com/BurntSushi/ripgrep), the
[tree-sitter CLI](https://github.com/tree-sitter/tree-sitter) with a C compiler, and a
[Nerd Font](https://www.nerdfonts.com) for file icons. On macOS:

```sh
brew install neovim ripgrep tree-sitter
brew install --cask font-meslo-lg-nerd-font
git clone https://github.com/fschrhunt/pure.nvim ~/dev/pure.nvim
~/dev/pure.nvim/x install
```

`./x install` links `~/.config/nvim` to the checkout and refuses to replace an existing config.
The first launch installs the plugins at the versions in `nvim-pack-lock.json` and builds the
tree-sitter parsers in the background.

Language servers aren't installed without asking. Open a file whose language server is missing,
and a toast asks whether to install it: `Space y` for yes, `Space n` for no. See [languages](docs/languages.md) for
the 25 supported languages.

## Keys

Everyday actions have a Space key. Press Space and pause to see them listed; everything else is
in the command palette, along with Neovim's own code keys.

| Key | Action | Key | Action |
| --- | --- | --- | --- |
| `Space p` | Command palette | `Space d` | Show problems |
| `Space f` | Find a file | `Space w` | Save |
| `Space /` | Search text in project | `Space q` | Close |
| `Space r` | Recent files | `Space -` | Split below |
| `Space ?` | Search help | `Space +` | Split right |
| `Space [` | Go back | `Space ]` | Go forward |

`Space [` and `Space ]` are back and forward, like a browser's: through the files and folders
you've visited. Open a file from the explorer (`:explore`), and `Space [` returns to that folder.
In the explorer, `[` and `]` go back and forward through folders. Everyday actions are also
commands, like `:back` (`:b`), `:forward` (`:f`), `:find`, and `:close`. [All keys](docs/keys.md) ·
[All commands](docs/commands.md)

## Docs

- [Keys](docs/keys.md): every key worth knowing, in the editor, the picker, and the file explorer.
- [Commands](docs/commands.md): plain-word commands like `:back`, `:find`, and `:close`.
- [Languages](docs/languages.md): the supported languages, installing their servers, formatting,
  and adding a language.
- [Colors](docs/colors.md): the palette, what it colors, and how to change it.
- [Plugins](docs/plugins.md): the two plugins, their versions, and updating them.

To add an action of your own, add one line to the list in `lua/pure/actions.lua`. It appears in
the palette, and gets its key and command there if you give it them.

## License

[MIT](LICENSE)

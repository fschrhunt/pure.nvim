# pure.nvim

A clean, intuitive Neovim. Built on what Neovim 0.12 ships with, plus two plugins for what it
can't do alone: [mini.nvim](https://github.com/nvim-mini/mini.nvim) for icons, the picker, the file
explorer, and git changes, and [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter)
for syntax. Language servers and formatting are configured here, in plain files.

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

Language servers are separate programs. pure.nvim starts the ones it finds:

```sh
brew install gopls typescript-language-server basedpyright ruff lua-language-server bash-language-server
npm install -g @astrojs/language-server
```

## Keys

Everyday actions have a Space key. Press Space and pause to see them listed; everything else is
in the command palette, along with Neovim's own code keys.

| Key | Action | Key | Action |
| --- | --- | --- | --- |
| `Space p` | Command palette | `Space d` | Show problems |
| `Space f` | Find a file | `Space w` | Save |
| `Space /` | Search text in project | `Space q` | Close file |
| `Space e` | Browse folder | `Space -` | Split below |
| `Space r` | Recent files | `Space +` | Split right |
| `Space ?` | Search help | `Space x` | Close window |

`Ctrl-o` steps back to where you were. In the file explorer, `h` backs out of a folder, `l` goes
in, and `Enter` opens a file.

## Code

Each language server brings errors as you type, go to definition (`Ctrl-]`), docs (`K`), rename
(`grn`), and code actions (`gra`). Suggestions appear while you type: `Tab` moves through them and
`Enter` accepts. Files are formatted on save, with Prettier in projects that configure it and the
language server's formatter everywhere else.

Configured languages: Go, TypeScript and JavaScript, Astro, Python, Lua, and shell.

## Make it yours

- Add an action with one line in `lua/pure/actions.lua`. It shows up in the palette and gets its
  key there.
- Change a color once in the palette table at the top of `colors/pure.lua`.
- Add a language with its parser in `lua/pure/syntax.lua`, a short `lsp/<server>.lua` file, and
  the server's name in `lua/pure/code.lua`.

## License

[MIT](LICENSE)

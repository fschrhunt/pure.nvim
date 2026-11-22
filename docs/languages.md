# Languages

Every language gets syntax colors, and the 25 below also get a language server for errors,
completion, and go to definition. Nothing is installed without asking: open a file whose language
server is missing, and a toast in the bottom-right corner asks whether to install it. Press `Space y`
or click Yes to install it, `Space n` or No to skip. The toast never takes the cursor and closes on
its own if you ignore it; `:install` works any time later.

## Syntax

Colors and folding come from tree-sitter and work for every language nvim-treesitter supports.
The first time you open a file in a new language, its parser is built in the background (this
needs the tree-sitter CLI and a C compiler); the file switches to full colors when it's ready.

## Language servers

Each language has a file in `lsp/`, named after it, with the server's command and the command
`:install` runs.

| Language | File | Server | Installed with |
| --- | --- | --- | --- |
| Astro | `astro.lua` | @astrojs/language-server | npm |
| Bash and sh | `bash.lua` | bash-language-server | Homebrew |
| C, C++, Objective-C | `c.lua` | clangd | Apple's command line tools |
| CSS, SCSS, Less | `css.lua` | vscode-css-language-server | Homebrew |
| Dockerfile | `docker.lua` | dockerfile-language-server | Homebrew |
| Elixir | `elixir.lua` | elixir-ls | Homebrew |
| Go | `go.lua` | gopls | Homebrew |
| Haskell | `haskell.lua` | haskell-language-server | Homebrew |
| HTML | `html.lua` | vscode-html-language-server | Homebrew |
| Java | `java.lua` | jdtls | Homebrew |
| JSON | `json.lua` | vscode-json-language-server | Homebrew |
| Kotlin | `kotlin.lua` | kotlin-language-server | Homebrew |
| Lua | `lua.lua` | lua-language-server | Homebrew |
| Markdown | `markdown.lua` | marksman | Homebrew |
| PHP | `php.lua` | intelephense | npm |
| Python | `python.lua` | basedpyright | Homebrew |
| Ruby | `ruby.lua` | ruby-lsp | Homebrew |
| Rust | `rust.lua` | rust-analyzer | Homebrew |
| Svelte | `svelte.lua` | svelte-language-server | npm |
| Swift | `swift.lua` | sourcekit-lsp | Apple's command line tools |
| Terraform | `terraform.lua` | terraform-ls | Homebrew |
| TOML | `toml.lua` | taplo | Homebrew |
| TypeScript, JavaScript | `typescript.lua` | typescript-language-server | Homebrew |
| YAML | `yaml.lua` | yaml-language-server | Homebrew |
| Zig | `zig.lua` | zls | Homebrew |

A server that isn't installed simply doesn't start. Each language asks once per session, so the
toast won't follow you around.

## What a language server gives you

- Problems as you type. A colored `●` replaces the line number, and the message appears at the
  end of the line your cursor is on. `Space d` lists every problem.
- Suggestions while typing, with imports added when you accept one.
- Go to definition, docs, references, rename, and code actions; see [keys](keys.md#code).

## Formatting

Files are formatted when you save, and `:format` formats on demand:

1. In a project with a Prettier config (`.prettierrc`, `prettier.config.js`, and the like) and
   Prettier installed in its `node_modules`, Prettier formats JavaScript, TypeScript, Astro, CSS,
   HTML, JSON, Markdown, and YAML.
2. Python is formatted with [ruff](https://docs.astral.sh/ruff/) when it's installed
   (`brew install ruff`).
3. Everything else uses its language server's formatter, when it has one.

Only the lines that change are rewritten, so the cursor and marks stay put. If the formatter can't
parse the file, the save goes through unformatted and a toast says why.

## Adding a language

Create `lsp/<language>.lua` with the server's command, file types, the files that mark a
project's root, and how to install it. It starts automatically when installed, and `:install`
works for it right away:

```lua
-- Gleam: the Gleam language server, part of the gleam CLI.
return {
  cmd = { 'gleam', 'lsp' },
  filetypes = { 'gleam' },
  root_markers = { 'gleam.toml', '.git' },
  install = 'brew install gleam',
}
```

Restart Neovim to pick it up. If the server doesn't start, `:checkhealth vim.lsp` shows why.

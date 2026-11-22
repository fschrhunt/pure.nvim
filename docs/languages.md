# Languages

Every language gets syntax colors, and the 25 below also get a language server: completion as you
type, errors and warnings, go to definition, rename, and code actions. Prose (Markdown, commit
messages, plain text) gets spelling and grammar checking.

pure installs language servers itself, into its own folder. No package manager is needed. Open a
file whose servers are missing, and one toast in the bottom-right corner asks whether to install
them, saying what each adds: `Space y` or a click on Yes installs them, `Space n`, No, or the
toast's `x` skips.
The toast never takes the cursor and stays until you answer; after Yes it shows the progress and
the result. A server already on your `PATH` is used without asking.

## Syntax

Colors and folding come from tree-sitter and work for every language nvim-treesitter supports.
The first time you open a file in a new language, its parser is built in the background (this
needs the tree-sitter CLI and a C compiler); the file switches to full colors when it's ready.

## Language servers

Each language has a file in `lsp/`, named after it, with the server's command, its settings, and
where to get it.

| Language | File | Server | Comes from |
| --- | --- | --- | --- |
| Astro | `astro.lua` | @astrojs/language-server | npm |
| Bash and sh | `bash.lua` | bash-language-server | npm |
| C, C++, Objective-C | `c.lua` | clangd | clangd releases |
| CSS, SCSS, Less | `css.lua` | vscode-css-language-server | npm |
| Dockerfile | `docker.lua` | dockerfile-language-server | npm |
| Elixir | `elixir.lua` | elixir-ls | elixir-ls releases; runs on your Elixir |
| Go | `go.lua` | gopls | `go install` |
| Haskell | `haskell.lua` | haskell-language-server | `ghcup`, to match your GHC |
| HTML | `html.lua` | vscode-html-language-server | npm |
| Java | `java.lua` | jdtls | Eclipse downloads; runs on Java 25+ |
| JSON | `json.lua` | vscode-json-language-server | npm |
| Kotlin | `kotlin.lua` | kotlin-language-server | its releases, pinned; runs on Java 11+ |
| Lua | `lua.lua` | lua-language-server | its releases |
| Markdown | `markdown.lua` | marksman | its releases |
| PHP | `php.lua` | intelephense | npm |
| Python | `python.lua` | basedpyright | npm |
| Ruby | `ruby.lua` | ruby-lsp | `gem` |
| Rust | `rust.lua` | rust-analyzer | its releases |
| Svelte | `svelte.lua` | svelte-language-server | npm |
| Swift | `swift.lua` | sourcekit-lsp | the Swift toolchain |
| Terraform | `terraform.lua` | terraform-ls | HashiCorp releases |
| TOML | `toml.lua` | taplo | npm |
| TypeScript, JavaScript | `typescript.lua` | typescript-language-server | npm |
| YAML | `yaml.lua` | yaml-language-server | npm |
| Zig | `zig.lua` | zls | its releases |
| Spelling and grammar | `harper.lua` | harper-ls | its releases |

npm servers run on your Node if you have one; otherwise pure downloads the current Node.js LTS
once, into the same folder. Java and Kotlin servers run on your Java if it's new enough;
otherwise pure downloads a Temurin runtime once. A few servers run on their language itself (Go,
Ruby, Haskell, Elixir, Swift), which anyone writing that language already has; if it's missing,
the install says so before downloading anything.

## Installing, updating, and removing

- `:install` installs what the current file is missing; `:install rust` or `:install harper`
  installs or updates one by name.
- About once a week, pure checks the servers it installed for newer versions and asks in a toast
  before updating. "Update language servers" in the palette updates them all now.
- Everything lives in `~/.local/share/nvim/servers`. Delete that folder to remove them all.

Every download is checked against a SHA-256: the one its project publishes, or, for the Kotlin
server, whose project publishes none, one pinned in its recipe. A download that can't be checked
isn't installed. npm, go, and gem check their own packages.

A server you install yourself, with any package manager, is used as is: pure only installs what
it can't find on `PATH`, and leaves updating yours to you.

## For scripts and coding agents

`nvim --headless '+Install rust' +qa` installs a server and waits for it to finish. Anything placed
in `~/.local/share/nvim/servers/bin` with the name of a server's command is used like an
installed one.

## What a language server gives you

- Problems as you type: a wavy underline under the exact spot, a colored `●` in place of the line
  number, and the message at the end of the line your cursor is on. `Space d` lists every problem.
- Suggestions while typing, from the server alone, with imports added when you accept one.
- Go to definition, docs, references, rename, and code actions; see [keys](keys.md#code).

## Formatting

Files are formatted when you save, and `:format` formats on demand:

1. In a project with a Prettier config (`.prettierrc`, `prettier.config.js`, and the like) and
   Prettier installed in its `node_modules`, Prettier formats JavaScript, TypeScript, Astro, CSS,
   HTML, JSON, Markdown, and YAML.
2. Python is formatted with [ruff](https://docs.astral.sh/ruff/) when it's installed.
3. Everything else uses its language server's formatter, when it has one.

Only the lines that change are rewritten, so the cursor and marks stay put. If the formatter can't
parse the file, the save goes through unformatted and a toast says why.

## Adding a language

Create `lsp/<language>.lua` with the server's command, file types, the files that mark a project's
root, and where to get it. It starts automatically when installed, and `:install` works for it
right away:

```lua
-- Gleam: the Gleam language server, part of the gleam CLI.
return {
  cmd = { 'gleam', 'lsp' },
  filetypes = { 'gleam' },
  root_markers = { 'gleam.toml', '.git' },
  install = {
    github = 'gleam-lang/gleam',
    files = {
      ['mac-arm64'] = 'gleam-v{version}-aarch64-apple-darwin.tar.gz',
      ['mac-x64'] = 'gleam-v{version}-x86_64-apple-darwin.tar.gz',
      ['linux-arm64'] = 'gleam-v{version}-aarch64-unknown-linux-musl.tar.gz',
      ['linux-x64'] = 'gleam-v{version}-x86_64-unknown-linux-musl.tar.gz',
    },
    bin = 'gleam',
  },
}
```

`lua/pure/servers.lua` describes every kind of `install` recipe. Restart Neovim to pick up a new
file. If the server doesn't start, `:checkhealth vim.lsp` shows why.

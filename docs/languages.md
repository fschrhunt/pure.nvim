# Languages

Each language gets three things: a tree-sitter parser for syntax, a language server for code
smarts, and a formatter that runs on save. Parsers build automatically; language servers are
separate programs you install once.

## Configured languages

| Language | Language server | Install | Formats with |
| --- | --- | --- | --- |
| Go | gopls | `brew install gopls` | gofmt, through gopls |
| TypeScript, JavaScript | typescript-language-server | `brew install typescript-language-server` | Prettier, or the server |
| Astro | @astrojs/language-server | `npm install -g @astrojs/language-server` | Prettier, or the server |
| Python | basedpyright and ruff | `brew install basedpyright ruff` | ruff |
| Lua | lua-language-server | `brew install lua-language-server` | the server |
| Shell | bash-language-server | `brew install bash-language-server` | — |

A server that isn't installed simply doesn't start; nothing breaks. Parsers also cover CSS, HTML,
JSON, YAML, TOML, Markdown, diffs, and commit messages.

## What a language server gives you

- Problems as you type. A colored `●` replaces the line number, and the message appears at the
  end of the line your cursor is on. `Space d` lists every problem.
- Suggestions while typing, with imports added when you accept one.
- Go to definition, docs, references, rename, and code actions; see [keys](keys.md#code).

## Formatting

Files are formatted when you save, and `:Format` (or "Format file" in the palette) formats on
demand. The rule is simple:

1. In a project with a Prettier config (`.prettierrc`, `prettier.config.js`, and the like) and
   Prettier installed in its `node_modules`, Prettier formats JavaScript, TypeScript, Astro, CSS,
   HTML, JSON, Markdown, and YAML.
2. Everything else uses its language server's formatter, when it has one.

Only the lines that change are rewritten, so the cursor and marks stay put. If Prettier can't
parse the file, the save goes through unformatted and a message says why.

## Adding a language

1. Add its parser name to the list in `lua/pure/syntax.lua`. The names are listed in
   [nvim-treesitter's supported languages](https://github.com/nvim-treesitter/nvim-treesitter/blob/main/SUPPORTED_LANGUAGES.md).
2. Create `lsp/<server>.lua` with the server's command, file types, and the files that mark a
   project's root. The existing files are good templates:

   ```lua
   -- Rust: rust-analyzer (brew install rust-analyzer).
   return {
     cmd = { 'rust-analyzer' },
     filetypes = { 'rust' },
     root_markers = { 'Cargo.toml', '.git' },
   }
   ```

3. Add the server's name to `vim.lsp.enable` in `lua/pure/code.lua`.
4. Restart Neovim, open a file, and check `:checkhealth vim.lsp` if the server doesn't start.

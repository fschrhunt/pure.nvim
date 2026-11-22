-- Syntax: tree-sitter parsers for the languages in use, plus highlighting
-- and folding wherever a parser exists. Other files use Neovim's regex
-- syntax, which the color scheme also covers.

-- Builds missing parsers in the background; a no-op once they exist.
-- Requires the tree-sitter CLI and a C compiler.
require('nvim-treesitter').install({
  'astro',
  'bash',
  'css',
  'diff',
  'gitcommit',
  'go',
  'gomod',
  'gosum',
  'html',
  'javascript',
  'json',
  'lua',
  'markdown',
  'markdown_inline',
  'python',
  'toml',
  'tsx',
  'typescript',
  'yaml',
})

vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('pure.syntax', {}),
  desc = 'Use tree-sitter highlighting and folding when a parser exists',
  callback = function(args)
    if pcall(vim.treesitter.start, args.buf) then
      vim.wo[0][0].foldmethod = 'expr'
      vim.wo[0][0].foldexpr = 'v:lua.vim.treesitter.foldexpr()'
    end
  end,
})

vim.o.foldlevelstart = 99 -- files open unfolded; zc and zo close and open a fold
vim.o.foldtext = '' -- folded lines keep their syntax colors

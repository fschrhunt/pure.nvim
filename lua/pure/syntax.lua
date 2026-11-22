-- Syntax: tree-sitter highlighting and folding for every language
-- nvim-treesitter supports. A language's parser is built in the background the
-- first time you open one of its files (this needs the tree-sitter CLI and a C
-- compiler); until it's ready, Neovim's regex syntax colors the file.

local treesitter = require('nvim-treesitter')
local available -- parser names nvim-treesitter can build, read on first need

-- Highlight and fold the buffer with tree-sitter, if its parser is installed.
local function start(buf, lang)
  if not pcall(vim.treesitter.start, buf, lang) then
    return false
  end
  for _, win in ipairs(vim.fn.win_findbuf(buf)) do
    vim.wo[win][0].foldmethod = 'expr'
    vim.wo[win][0].foldexpr = 'v:lua.vim.treesitter.foldexpr()'
  end
  return true
end

vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('pure.syntax', {}),
  desc = 'Use tree-sitter, building the parser on first use',
  callback = function(args)
    local buf, lang = args.buf, vim.treesitter.language.get_lang(args.match)
    if not lang or start(buf, lang) then
      return
    end
    available = available or treesitter.get_available()
    if not vim.tbl_contains(available, lang) then
      return
    end
    treesitter.install(lang):await(function(err)
      if not err then
        vim.schedule(function()
          -- Neovim caches where runtime files are; on a first launch that
          -- cache predates the parser folder. Setting the path refreshes it.
          vim.o.runtimepath = vim.o.runtimepath
          if vim.api.nvim_buf_is_valid(buf) then
            start(buf, lang)
          end
        end)
      end
    end)
  end,
})

vim.o.foldlevelstart = 99 -- files open unfolded; zc and zo close and open a fold
vim.o.foldtext = '' -- folded lines keep their syntax colors

-- pure.nvim: a clean, intuitive Neovim.
--
-- Space p opens the command palette, which lists every action with its key.
-- Each module owns one concern. They load in this order because later ones
-- use what earlier ones set up.

vim.g.mapleader = ' '

require('pure.options') -- look and behavior
require('pure.plugins') -- installs plugins; sets up icons, picker, explorer, git and key hints
require('pure.syntax') -- tree-sitter highlighting and folding
require('pure.code') -- language servers, completion and formatting
require('pure.actions') -- Space keys and the command palette

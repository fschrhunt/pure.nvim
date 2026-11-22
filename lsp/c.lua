-- C and C++: clangd, which ships with Apple's command line tools.
return {
  cmd = { 'clangd' },
  filetypes = { 'c', 'cpp', 'objc', 'objcpp', 'cuda' },
  root_markers = { 'compile_commands.json', '.clangd', 'CMakeLists.txt', 'Makefile', '.git' },
  install = vim.fn.has('mac') == 1 and 'xcode-select --install' or 'brew install llvm',
}

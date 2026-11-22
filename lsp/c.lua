-- C and C++: clangd. Apple's command line tools include it; otherwise it's
-- downloaded from the clangd releases.
return {
  cmd = { 'clangd' },
  filetypes = { 'c', 'cpp', 'objc', 'objcpp', 'cuda' },
  root_markers = { 'compile_commands.json', '.clangd', 'CMakeLists.txt', 'Makefile', '.git' },
  install = {
    github = 'clangd/clangd',
    files = {
      ['mac-arm64'] = 'clangd-mac-{version}.zip',
      ['mac-x64'] = 'clangd-mac-{version}.zip',
      ['linux-arm64'] = 'clangd-linux-{version}.zip',
      ['linux-x64'] = 'clangd-linux-{version}.zip',
    },
    bin = 'clangd_{version}/bin/clangd',
  },
}

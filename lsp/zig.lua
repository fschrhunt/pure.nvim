-- Zig: zls.
return {
  cmd = { 'zls' },
  filetypes = { 'zig', 'zir' },
  root_markers = { 'zls.json', 'build.zig', '.git' },
  install = {
    github = 'zigtools/zls',
    files = {
      ['mac-arm64'] = 'zls-aarch64-macos.tar.xz',
      ['mac-x64'] = 'zls-x86_64-macos.tar.xz',
      ['linux-arm64'] = 'zls-aarch64-linux.tar.xz',
      ['linux-x64'] = 'zls-x86_64-linux.tar.xz',
    },
  },
}

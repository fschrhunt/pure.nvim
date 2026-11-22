-- Rust: rust-analyzer.
return {
  cmd = { 'rust-analyzer' },
  filetypes = { 'rust' },
  root_markers = { 'Cargo.toml', '.git' },
  install = {
    github = 'rust-lang/rust-analyzer',
    files = {
      ['mac-arm64'] = 'rust-analyzer-aarch64-apple-darwin.gz',
      ['mac-x64'] = 'rust-analyzer-x86_64-apple-darwin.gz',
      ['linux-arm64'] = 'rust-analyzer-aarch64-unknown-linux-gnu.gz',
      ['linux-x64'] = 'rust-analyzer-x86_64-unknown-linux-gnu.gz',
    },
  },
}

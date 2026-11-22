-- Rust: rust-analyzer.
return {
  cmd = { 'rust-analyzer' },
  filetypes = { 'rust' },
  root_markers = { 'Cargo.toml', '.git' },
  install = 'brew install rust-analyzer',
}

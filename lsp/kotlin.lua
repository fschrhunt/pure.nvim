-- Kotlin: kotlin-language-server.
return {
  cmd = { 'kotlin-language-server' },
  filetypes = { 'kotlin' },
  root_markers = { 'settings.gradle.kts', 'settings.gradle', 'build.gradle.kts', '.git' },
  install = 'brew install kotlin-language-server',
}

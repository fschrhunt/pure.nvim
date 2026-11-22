-- Kotlin: kotlin-language-server. Runs on Java, which Kotlin needs anyway.
return {
  cmd = { 'kotlin-language-server' },
  filetypes = { 'kotlin' },
  root_markers = { 'settings.gradle.kts', 'settings.gradle', 'build.gradle.kts', '.git' },
  install = {
    github = 'fwcd/kotlin-language-server',
    files = {
      ['mac-arm64'] = 'server.zip',
      ['mac-x64'] = 'server.zip',
      ['linux-arm64'] = 'server.zip',
      ['linux-x64'] = 'server.zip',
    },
    bin = 'server/bin/kotlin-language-server',
  },
}

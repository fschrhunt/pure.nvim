-- Kotlin: kotlin-language-server. Runs on Java 11 or newer; pure provides one if
-- needed.
return {
  cmd = { 'kotlin-language-server' },
  filetypes = { 'kotlin' },
  root_markers = { 'settings.gradle.kts', 'settings.gradle', 'build.gradle.kts', '.git' },
  install = {
    -- Pinned: the project publishes no checksums, so this one is fixed in the recipe.
    url = 'https://github.com/fwcd/kotlin-language-server/releases/download/1.3.13/server.zip',
    version = '1.3.13',
    sha256 = '4fe7d71d087b307c7869036171bd9d8c6a4284cd7c25b89098b0a24eb2d9b6d2',
    bin = 'server/bin/kotlin-language-server',
    java = 11,
  },
}

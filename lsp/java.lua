-- Java: jdtls (Eclipse JDT Language Server).
return {
  cmd = { 'jdtls' },
  filetypes = { 'java' },
  root_markers = { 'pom.xml', 'build.gradle', 'build.gradle.kts', 'settings.gradle', '.git' },
  install = 'brew install jdtls',
}

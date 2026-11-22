-- Java: jdtls (Eclipse JDT Language Server). Runs on Java 21 or newer.
return {
  cmd = { 'jdtls' },
  filetypes = { 'java' },
  root_markers = { 'pom.xml', 'build.gradle', 'build.gradle.kts', 'settings.gradle', '.git' },
  install = {
    url = 'https://download.eclipse.org/jdtls/snapshots/jdt-language-server-latest.tar.gz',
    bin = 'bin/jdtls',
  },
}

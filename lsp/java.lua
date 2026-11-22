-- Java: jdtls (Eclipse JDT Language Server). Runs on Java 25 or newer; pure
-- provides one if needed.
return {
  cmd = { 'jdtls' },
  filetypes = { 'java' },
  root_markers = { 'pom.xml', 'build.gradle', 'build.gradle.kts', 'settings.gradle', '.git' },
  install = {
    latest = 'https://download.eclipse.org/jdtls/snapshots/latest.txt',
    url = 'https://download.eclipse.org/jdtls/snapshots/{file}',
    sums = 'https://download.eclipse.org/jdtls/snapshots/{file}.sha256',
    bin = 'bin/jdtls',
    java = 25,
  },
}

-- Servers: installs language servers into pure's own folder, so no package
-- manager is needed. Each lsp/<name>.lua says where its server comes from
-- (`install`), one of:
--
--   github = 'owner/repo', files = { ['mac-arm64'] = name, ... }, bin = path
--       A release file per system ({version} is the release, without a v).
--   url = template, files = {...}, sums = template, github = 'owner/repo'
--       A download from elsewhere, versioned by the GitHub release.
--   url = address, version = v, sha256 = sum
--       One pinned download, for projects that publish no checksum.
--   latest = address, url = template, sums = template
--       A download whose current file name ({file}) is read from latest.
--   npm = { packages }, bin = program
--       Run with your Node, or with a copy downloaded once into the folder.
--   go = module, gem = name, tool = command
--       The language's own tool, for servers that only ship that way.
--
-- Any recipe can add `needs = 'command'` (checked before downloading) and
-- `java = 21` (a minimum Java: yours if it's new enough, otherwise a Temurin
-- runtime downloaded once into the folder).
--
-- Every download is checked against a SHA-256: the one its project publishes,
-- or the recipe's pinned one. A download with neither isn't installed. npm,
-- go, and gem check their own packages.
-- The folder's bin/ comes first on PATH, so a program placed there by hand or
-- by a coding agent is used like an installed one.
--
-- M.install(name, done) installs or updates one; M.installed() lists them;
-- M.check_updates() asks about newer versions at most once a week; M.check()
-- makes sure every recipe still finds its download.

local M = {}

M.dir = vim.fs.joinpath(vim.fn.stdpath('data'), 'servers')
local bin = vim.fs.joinpath(M.dir, 'bin')
local record_file = vim.fs.joinpath(M.dir, 'installed.json')
vim.env.PATH = bin .. ':' .. vim.env.PATH

-- This system, as recipes name it: mac-arm64, mac-x64, linux-arm64, linux-x64.
local uname = vim.uv.os_uname()
local arch = (uname.machine == 'arm64' or uname.machine == 'aarch64') and 'arm64' or 'x64'
local platform = (uname.sysname == 'Darwin' and 'mac' or 'linux') .. '-' .. arch

-- Record of what pure installed: { servers = { name = version }, checked = time }.
local function read_record()
  local ok, data = pcall(
    function() return vim.json.decode(table.concat(vim.fn.readfile(record_file), '\n')) end
  )
  return ok and data or { servers = {} }
end
local function write_record(data)
  vim.fn.mkdir(M.dir, 'p')
  vim.fn.writefile({ vim.json.encode(data) }, record_file)
end

-- Steps of an install run one after another inside a coroutine; each command
-- waits for its result without blocking the editor.
local function run(cmd, opts)
  local co = coroutine.running()
  vim.system(cmd, vim.tbl_extend('force', { text = true }, opts or {}), function(result)
    vim.schedule(function() coroutine.resume(co, result) end)
  end)
  local result = coroutine.yield()
  if result.code ~= 0 then
    local output = vim.split(vim.trim((result.stderr or '') .. '\n' .. (result.stdout or '')), '\n')
    error(('%s failed: %s'):format(cmd[1], output[#output]), 0)
  end
  return result.stdout, result.stderr
end

-- GitHub allows few anonymous API calls an hour; a GITHUB_TOKEN, when set
-- (as in CI), raises that.
local function fetch_json(url)
  local curl = { 'curl', '-fsSL', url }
  if vim.env.GITHUB_TOKEN and url:match('^https://api%.github%.com/') then
    vim.list_extend(curl, { '-H', 'Authorization: Bearer ' .. vim.env.GITHUB_TOKEN })
  end
  return vim.json.decode((run(curl)))
end

local function sha256(file)
  local command = vim.fn.executable('sha256sum') == 1 and { 'sha256sum', file }
    or { 'shasum', '-a', '256', file }
  return run(command):match('^%x+')
end

-- Downloads url to file, checking it against an expected SHA-256 if given.
local function download(url, file, expected)
  run({ 'curl', '-fsSL', '-o', file, url })
  if expected and sha256(file) ~= expected:lower() then
    error('the download of ' .. vim.fs.basename(url) .. " didn't match its published checksum", 0)
  end
end

-- Unpacks an archive (or a single gzipped program) into dir.
local function unpack(file, dir, name)
  vim.fn.mkdir(dir, 'p')
  if file:match('%.tar%.gz$') or file:match('%.tgz$') then
    run({ 'tar', '-xzf', file, '-C', dir })
  elseif file:match('%.tar%.xz$') then
    run({ 'tar', '-xJf', file, '-C', dir })
  elseif file:match('%.zip$') or file:match('%.sit$') then
    run({ 'unzip', '-q', '-o', file, '-d', dir })
  elseif file:match('%.gz$') then
    run({ 'sh', '-c', 'gunzip -c "$1" > "$2"', 'sh', file, vim.fs.joinpath(dir, name) })
  else
    run({ 'mv', file, vim.fs.joinpath(dir, name) })
  end
end

-- Puts a small launcher for program in bin/, named command. env sets
-- variables for the program; a `path` entry goes in front of the current PATH.
local function link(command, program, env)
  vim.fn.mkdir(bin, 'p')
  local lines = { '#!/bin/sh' }
  for key, value in pairs(env or {}) do
    if key == 'path' then
      table.insert(lines, ('export PATH=%s:"$PATH"'):format(vim.fn.shellescape(value)))
    else
      table.insert(lines, ('export %s=%s'):format(key, vim.fn.shellescape(value)))
    end
  end
  table.insert(lines, ('exec %s "$@"'):format(vim.fn.shellescape(program)))
  local launcher = vim.fs.joinpath(bin, command)
  vim.fn.writefile(lines, launcher)
  vim.uv.fs_chmod(program, tonumber('755', 8))
  vim.uv.fs_chmod(launcher, tonumber('755', 8))
end

-- A repository's latest release, remembered for ten minutes so a check or a
-- run of installs asks GitHub once per repository.
local releases = {}
local function latest_release(repo)
  local cached = releases[repo]
  if not cached or os.time() - cached.time > 600 then
    cached = {
      time = os.time(),
      release = fetch_json('https://api.github.com/repos/' .. repo .. '/releases/latest'),
    }
    releases[repo] = cached
  end
  return cached.release
end

-- A release's version: its tag without a prefix like v or name/v.
local function version_of(release) return (release.tag_name:gsub('^.*/', ''):gsub('^v', '')) end

-- The SHA-256 for a file, from a sums file listing many or holding just one.
local function sum_for(sums, file)
  return sums:match('(%x+)%s+%*?' .. vim.pesc(file)) or sums:match('^%s*(%x+)%s*$')
end

-- Java for servers that run on it: yours if it's at least version min,
-- otherwise a Temurin runtime downloaded once into the folder: Java 21, the
-- long-term release every server here runs on, or min if a server needs newer.
-- Returns the downloaded runtime's home, or nil to use yours.
local function java_home(min)
  -- macOS has a java placeholder that fails when no Java is installed.
  local ok, _, info = pcall(run, { 'java', '-version' })
  if ok and tonumber(info:match('version "(%d+)') or 0) >= min then
    return nil
  end
  local release = math.max(min, 21)
  local dir = vim.fs.joinpath(M.dir, 'runtimes', 'java-' .. release)
  local home = uname.sysname == 'Darwin' and vim.fs.joinpath(dir, 'Contents', 'Home') or dir
  if vim.uv.fs_stat(vim.fs.joinpath(home, 'bin', 'java')) then
    return home
  end
  local query = ('https://api.adoptium.net/v3/assets/latest/%d/hotspot?os=%s&architecture=%s&image_type=jre'):format(
    release,
    uname.sysname == 'Darwin' and 'mac' or 'linux',
    arch == 'arm64' and 'aarch64' or 'x64'
  )
  local package = fetch_json(query)[1].binary.package
  local file = vim.fn.tempname() .. '.tar.gz'
  download(package.link, file, package.checksum)
  vim.fn.mkdir(dir, 'p')
  run({ 'tar', '-xzf', file, '-C', dir, '--strip-components=1' })
  return home
end

-- Node for npm servers: yours if installed, otherwise the current LTS release,
-- downloaded once into the folder.
local function node_dir()
  if vim.fn.executable('node') == 1 and vim.fn.executable('npm') == 1 then
    return vim.fs.dirname(vim.fn.exepath('node'))
  end
  local dir = vim.fs.joinpath(M.dir, 'runtimes', 'node')
  if vim.uv.fs_stat(vim.fs.joinpath(dir, 'bin', 'node')) then
    return vim.fs.joinpath(dir, 'bin')
  end
  local release = vim
    .iter(fetch_json('https://nodejs.org/dist/index.json'))
    :find(function(r) return r.lts end)
  local system = (uname.sysname == 'Darwin' and 'darwin' or 'linux') .. '-' .. arch
  local name = ('node-%s-%s.tar.gz'):format(release.version, system)
  local base = 'https://nodejs.org/dist/' .. release.version .. '/'
  local sum = run({ 'curl', '-fsSL', base .. 'SHASUMS256.txt' }):match('(%x+)%s+' .. vim.pesc(name))
  local file = vim.fn.tempname() .. '.tar.gz'
  download(base .. name, file, sum)
  vim.fn.mkdir(dir, 'p')
  run({ 'tar', '-xzf', file, '-C', dir, '--strip-components=1' })
  return vim.fs.joinpath(dir, 'bin')
end

-- Finds a release download for system (like mac-arm64) without fetching it.
-- Returns its url, its expected SHA-256, the version, and a function that
-- fills {version} and {file} in a recipe template. Errors when there's no
-- download for system or no checksum to check it against.
local function locate(recipe, command, system)
  local file_name = recipe.files and recipe.files[system]
  if recipe.files and not file_name then
    error(('%s has no download for %s.'):format(command, system), 0)
  end
  local release = recipe.github and latest_release(recipe.github)
  local version = release and version_of(release) or recipe.version or 'latest'
  if recipe.latest then
    file_name = vim.trim(run({ 'curl', '-fsSL', recipe.latest }))
    version = file_name:match('%d+%.%d+%.%d+') or file_name
  end
  local function fill(template)
    return (template:gsub('{version}', version):gsub('{file}', file_name or ''))
  end

  local url, expected
  if recipe.url then
    url = fill(recipe.url)
    expected = recipe.sha256
      or recipe.sums
        and sum_for(run({ 'curl', '-fsSL', fill(recipe.sums) }), vim.fs.basename(url))
  else
    local asset = vim.iter(release.assets):find(function(a) return a.name == fill(file_name) end)
    if not asset then
      error(('%s %s has no file %s.'):format(command, version, fill(file_name)), 0)
    end
    -- GitHub sends a missing digest as JSON null (vim.NIL).
    local digest = type(asset.digest) == 'string' and asset.digest:match('^sha256:(%x+)')
    url, expected = asset.browser_download_url, digest or nil
  end

  if not expected then
    error(("%s has no published checksum, so pure won't install it unchecked."):format(command), 0)
  end
  return url, expected, version, fill
end

-- Installs one server from its recipe; returns the installed version.
local function install(name, config)
  local recipe, command = config.install, config.cmd[1]
  local needs = recipe.needs
    or recipe.go and 'go'
    or recipe.gem and 'gem'
    or recipe.tool and recipe.tool:match('^%S+')
  if needs and vim.fn.executable(needs) == 0 then
    error(('%s needs %s. Install it, then try again.'):format(command, needs), 0)
  end
  local java = recipe.java and java_home(recipe.java)
  local env = java and { JAVA_HOME = java, path = vim.fs.joinpath(java, 'bin') } or nil

  if recipe.npm then
    local node = node_dir()
    local prefix = vim.fs.joinpath(M.dir, 'npm')
    local npm =
      { vim.fs.joinpath(node, 'npm'), 'install', '--prefix', prefix, '--no-fund', '--no-audit' }
    run(vim.list_extend(npm, recipe.npm), { env = { PATH = node .. ':' .. vim.env.PATH } })
    link(
      command,
      vim.fs.joinpath(prefix, 'node_modules', '.bin', recipe.bin or command),
      { path = node }
    )
    local package = vim.fs.joinpath(prefix, 'node_modules', recipe.npm[1], 'package.json')
    return vim.json.decode(table.concat(vim.fn.readfile(package), '\n')).version
  elseif recipe.go then
    run({ 'go', 'install', recipe.go }, { env = { GOBIN = bin } })
    return 'latest'
  elseif recipe.gem then
    local gems = vim.fs.joinpath(M.dir, 'gem')
    run({
      'gem',
      'install',
      '--no-document',
      '--install-dir',
      gems,
      '--bindir',
      vim.fs.joinpath(gems, 'bin'),
      recipe.gem,
    })
    link(command, vim.fs.joinpath(gems, 'bin', command), { GEM_HOME = gems, GEM_PATH = gems })
    return 'latest'
  elseif recipe.tool then
    run({ 'sh', '-c', recipe.tool })
    return 'latest'
  end

  if not (recipe.github or recipe.url or recipe.latest) then
    error(
      ('%s comes with %s; install that to use it.'):format(command, needs or 'its toolchain'),
      0
    )
  end

  local url, expected, version, fill = locate(recipe, command, platform)
  local folder = vim.fs.joinpath(M.dir, name)
  local file = vim.fs.joinpath(vim.fn.tempname(), vim.fs.basename(url))
  vim.fn.mkdir(vim.fs.dirname(file), 'p')
  download(url, file, expected)
  vim.fn.delete(folder, 'rf')
  unpack(file, folder, command)
  link(command, vim.fs.joinpath(folder, fill(recipe.bin or command)), env)
  return version
end

-- Installs (or updates) the server for lsp/<name>.lua in the background and
-- calls done(ok, message) when finished.
function M.install(name, done)
  local config = vim.lsp.config[name]
  coroutine.wrap(function()
    local ok, result = pcall(install, name, config)
    if ok then
      local record = read_record()
      record.servers[name] = result
      write_record(record)
    end
    done(ok, ok and (config.cmd[1] .. ' is installed.') or result)
  end)()
end

function M.installed() return read_record().servers end

-- Checks that every download recipe still finds a file with a checksum on
-- every system it lists, without downloading anything. Calls done(problems),
-- a list of messages, empty when all is well. For `./x servers`.
function M.check(done)
  coroutine.wrap(function()
    local problems = {}
    for _, file in ipairs(vim.api.nvim_get_runtime_file('lsp/*.lua', true)) do
      local name = vim.fn.fnamemodify(file, ':t:r')
      local config = vim.lsp.config[name]
      local recipe = config.install or {}
      if recipe.github or recipe.url or recipe.latest then
        for _, system in ipairs(recipe.files and vim.tbl_keys(recipe.files) or { platform }) do
          local ok, url = pcall(locate, recipe, config.cmd[1], system)
          if ok and recipe.sha256 then
            -- A pinned download has no listing to look it up in; ask for it.
            ok, url = pcall(run, { 'curl', '-fsSIL', '-o', '/dev/null', url })
          end
          if not ok then
            table.insert(problems, ('%s (%s): %s'):format(name, system, url))
          end
        end
      end
    end
    done(problems)
  end)()
end

-- The newest version a recipe can tell, without installing anything.
local function latest_version(recipe)
  if recipe.github then
    return version_of(latest_release(recipe.github))
  elseif recipe.latest then
    return vim.trim(run({ 'curl', '-fsSL', recipe.latest })):match('%d+%.%d+%.%d+')
  elseif recipe.npm and vim.fn.executable('npm') == 1 then
    return vim.trim(run({ 'npm', 'view', recipe.npm[1], 'version' }))
  end
end

-- At most once a week, check the servers pure installed for newer versions,
-- and ask before updating them. on_update(names) runs if you say yes.
function M.check_updates(on_update)
  local record = read_record()
  if os.time() - (record.checked or 0) < 7 * 24 * 60 * 60 or not next(record.servers) then
    return
  end
  record.checked = os.time()
  write_record(record)
  coroutine.wrap(function()
    local outdated = {}
    for name, version in pairs(record.servers) do
      local ok, latest = pcall(latest_version, vim.lsp.config[name].install)
      if ok and latest and latest ~= version then
        table.insert(outdated, name)
      end
    end
    if #outdated > 0 then
      on_update(outdated)
    end
  end)()
end

return M

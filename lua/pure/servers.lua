-- Servers: installs language servers into pure's own folder, so no package
-- manager is needed. Each lsp/<name>.lua says where its server comes from
-- (`install`), one of:
--
--   github = 'owner/repo', files = { ['mac-arm64'] = name, ... }, bin = path
--       A release file per system ({version} is the release, without a v).
--   url = template, files = {...}, sums = template, github = 'owner/repo'
--       A download from elsewhere, versioned by the GitHub release.
--   npm = { packages }, bin = program
--       Run with your Node, or with a copy downloaded once into the folder.
--   go = module, gem = name, tool = command
--       The language's own tool, for servers that only ship that way.
--
-- Downloads are checked against their published SHA-256 when there is one.
-- The folder's bin/ comes first on PATH, so a program placed there by hand or
-- by a coding agent is used like an installed one.
--
-- M.install(name, done) installs or updates one; M.installed() lists them;
-- M.check_updates() asks about newer versions at most once a week.

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
  return result.stdout
end

local function fetch_json(url) return vim.json.decode(run({ 'curl', '-fsSL', url })) end

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
  elseif file:match('%.zip$') then
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

local function latest_release(repo)
  return fetch_json('https://api.github.com/repos/' .. repo .. '/releases/latest')
end

-- Node for npm servers: yours if installed, otherwise the current LTS release,
-- downloaded once into the folder.
local function node_dir()
  if vim.fn.executable('node') == 1 and vim.fn.executable('npm') == 1 then
    return vim.fs.dirname(vim.fn.exepath('node'))
  end
  local dir = vim.fs.joinpath(M.dir, 'node')
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

-- Installs one server from its recipe; returns the installed version.
local function install(name, config)
  local recipe, command = config.install, config.cmd[1]
  local needs = { go = 'Go', gem = 'Ruby', tool = recipe.tool and recipe.tool:match('^%S+') }
  for key, label in pairs(needs) do
    if recipe[key] and vim.fn.executable(key == 'tool' and label or key) == 0 then
      error(('%s needs %s. Install it, then try again.'):format(command, label), 0)
    end
  end

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

  -- A release download: from GitHub, or from a URL versioned by GitHub.
  local file_name = recipe.files and recipe.files[platform]
  if recipe.files and not file_name then
    error(('%s has no download for %s.'):format(command, platform), 0)
  end
  local release = recipe.github and latest_release(recipe.github)
  local version = release and release.tag_name:gsub('^v', '') or 'latest'
  local function fill(template)
    return (template:gsub('{version}', version):gsub('{file}', file_name or ''))
  end

  local url, expected
  if recipe.url then
    url = fill(recipe.url)
    if recipe.sums then
      expected = run({ 'curl', '-fsSL', fill(recipe.sums) }):match(
        '(%x+)%s+' .. vim.pesc(vim.fs.basename(url))
      )
    end
  else
    local asset = vim.iter(release.assets):find(function(a) return a.name == fill(file_name) end)
    if not asset then
      error(('%s %s has no file %s.'):format(command, version, fill(file_name)), 0)
    end
    url, expected = asset.browser_download_url, asset.digest and asset.digest:match('^sha256:(%x+)')
  end

  local folder = vim.fs.joinpath(M.dir, name)
  local file = vim.fs.joinpath(vim.fn.tempname(), vim.fs.basename(url))
  vim.fn.mkdir(vim.fs.dirname(file), 'p')
  download(url, file, expected)
  vim.fn.delete(folder, 'rf')
  unpack(file, folder, command)
  link(command, vim.fs.joinpath(folder, fill(recipe.bin or command)))
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

-- The newest version a recipe can tell, without installing anything.
local function latest_version(recipe)
  if recipe.github then
    return latest_release(recipe.github).tag_name:gsub('^v', '')
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

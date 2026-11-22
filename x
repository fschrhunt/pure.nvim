#!/bin/sh
# Run the same checks locally and in CI, update plugins, and install this checkout.
set -eu
cd "$(dirname "$0")"

usage() {
    cat <<'USAGE'
usage: ./x [command]
  check     Default; check formatting, shell scripts, and that the config loads
  fmt       Format Lua files
  update    Update plugins and nvim-pack-lock.json
  sync      Install the plugin versions in nvim-pack-lock.json
  install   Link ~/.config/nvim to this checkout
  servers   Check that every language server recipe still finds a checksummed download
  hooks     Install the repository's Git hook
  help      Show this help
USAGE
}

# Run Neovim headless with this checkout as its config, wherever it lives.
nvim_here() {
    tmp=$(mktemp -d)
    trap 'rm -rf "$tmp"' EXIT
    ln -s "$PWD" "$tmp/nvim"
    XDG_CONFIG_HOME=$tmp nvim --headless "$@"
}

config_dir=${XDG_CONFIG_HOME:-$HOME/.config}/nvim

[ "$#" -le 1 ] || { usage >&2; exit 2; }
case "${1-check}" in
    check)
        stylua --check .
        shellcheck x .githooks/pre-commit .github/release/*.sh
        # Space p is mapped last, so it only exists if every module loaded.
        nvim_here +'lua if vim.fn.maparg("<Space>p", "n") == "" then vim.cmd.cquit() end' +qa
        echo 'pure.nvim loads cleanly'
        ;;
    fmt)
        stylua .
        ;;
    servers)
        # GitHub allows few anonymous API calls; use your gh login if you have one.
        if [ -z "${GITHUB_TOKEN-}" ] && command -v gh >/dev/null 2>&1; then
            GITHUB_TOKEN=$(gh auth token 2>/dev/null || true)
            export GITHUB_TOKEN
        fi
        nvim_here +'lua require("pure.servers").check(function(problems)
            for _, problem in ipairs(problems) do io.stderr:write(problem, "\n") end
            vim.cmd(#problems == 0 and "qa" or "cquit")
          end)'
        echo 'Every language server recipe finds its download'
        ;;
    update)
        nvim_here +'lua vim.pack.update(nil, { force = true })' +qa
        ;;
    sync)
        nvim_here +'lua vim.pack.update(nil, { force = true, target = "lockfile" })' +qa
        ;;
    install)
        if [ "$(readlink "$config_dir" 2>/dev/null)" = "$PWD" ]; then
            echo "$config_dir already points here"
        elif [ -e "$config_dir" ] || [ -L "$config_dir" ]; then
            echo "$config_dir already exists; move it aside first" >&2
            exit 1
        else
            mkdir -p "$(dirname "$config_dir")"
            ln -s "$PWD" "$config_dir"
            echo "Linked $config_dir to $PWD"
        fi
        ;;
    hooks)
        git config core.hooksPath .githooks
        echo 'Git hook installed.'
        ;;
    help|--help|-h)
        usage
        ;;
    *)
        usage >&2
        exit 2
        ;;
esac

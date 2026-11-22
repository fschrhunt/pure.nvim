#!/bin/sh
# Run the same checks locally and in CI, and install this checkout.
set -eu
cd "$(dirname "$0")"

usage() {
    cat <<'USAGE'
usage: ./x [command]
  check     Default; check formatting and that the config loads without errors
  fmt       Format Lua files
  install   Link ~/.config/nvim to this checkout
  help      Show this help
USAGE
}

config_dir=${XDG_CONFIG_HOME:-$HOME/.config}/nvim

case "${1-check}" in
    check)
        stylua --check .
        # Load the config from this checkout wherever it lives. Space p is
        # mapped last, so it only exists if every module loaded.
        tmp=$(mktemp -d)
        trap 'rm -rf "$tmp"' EXIT
        ln -s "$PWD" "$tmp/nvim"
        XDG_CONFIG_HOME=$tmp nvim --headless \
            +'lua if vim.fn.maparg("<Space>p", "n") == "" then vim.cmd.cquit() end' +qa
        echo 'pure.nvim loads cleanly'
        ;;
    fmt)
        stylua .
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
    help|--help|-h)
        usage
        ;;
    *)
        usage >&2
        exit 2
        ;;
esac

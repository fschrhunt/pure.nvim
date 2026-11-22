# Contributing

pure.nvim is a small Neovim config. Prefer what Neovim ships with and keep changes simple.
Development needs Neovim 0.12 or newer, Git, a POSIX shell, StyLua, ShellCheck, and the
tree-sitter CLI with a C compiler.

```sh
./x hooks   # once per clone
./x check   # formatting, ShellCheck, and a headless load of the config; CI runs the same checks
./x install # link ~/.config/nvim to this checkout
./x servers # check that every language server recipe still finds a checksummed download
```

`./x` defaults to `check`; run `./x help` for the other commands. See [AGENTS.md](AGENTS.md) for
where things live and the conventions. Update the README, `docs/`, and the changelog when behavior
changes.

Never include credentials or private file contents in issue reports. For bugs, include the
operating system, terminal, `nvim --version`, what you did, and what happened.

## Dependencies

Plugins are pinned in `nvim-pack-lock.json`. The [Dependencies workflow](.github/workflows/dependencies.yml)
runs `./x update` weekly and keeps one `deps/plugins` pull request open with a compare link for
each changed plugin. Run `./x update` to do the same locally, and `./x sync` after pulling a
lockfile change to install the recorded versions. The same workflow runs `./x servers`, so a
language server whose project renames its release files fails there first; fix its `lsp/` recipe. Dependabot opens one weekly pull request for
GitHub Actions updates. Review changes and required checks before merging.

## Releases

From a clean, up-to-date `main` checkout with Git and authenticated `gh`, run:

```sh
.github/release/release.sh v1.2.3            # opens a PR to name the Unreleased changelog section
.github/release/release.sh --dry-run v1.2.3  # after merging: verify the release without publishing
.github/release/release.sh v1.2.3            # after merging and updating main: requests the release
```

The helper keeps the checkout on main, requires passing CI on its exact commit, and asks Actions
to publish. The [release workflow](.github/workflows/release.yml) checks that main has not moved,
then runs `.github/release/verify.sh`, which rejects tags outside `main`'s history, commits
without passing main CI, and missing, duplicate, or empty changelog sections. It then creates the
tag and a GitHub release with that version's changelog notes. A maintainer can also push a valid
tag directly; it goes through the same checks. Use a new stable semantic version with no leading
zeros. Existing releases are never overwritten, and published tags are protected from moving.

By contributing you agree that your work is licensed under the project's MIT license.

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
where things live and the conventions. Update the README and `docs/` when behavior
changes; release notes are written when releasing.

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
.github/release/release.sh --dry-run v1.2.3  # show the changelog it would write; publishes nothing
.github/release/release.sh v1.2.3            # write the notes, then release
```

The helper drafts the notes from the pull requests merged since the last release and opens them
in your editor; what you save is published. It requires passing CI on the exact `main` commit
and asks the [release workflow](.github/workflows/release.yml) to release it. The workflow checks
that main has not moved and runs `.github/release/verify.sh`, which rejects invalid or existing
tags and commits without passing main CI. It then adds the notes to `CHANGELOG.md` in a release
commit on top of that main commit, tags it, publishes a GitHub release with the same notes, and
opens a `release/v1.2.3` pull request that brings the changelog to `main`; merge it after CI
passes. `CHANGELOG.md` is never edited by hand. Use a new stable semantic version with no
leading zeros. Existing releases are never overwritten, and published tags are protected from
moving.

By contributing you agree that your work is licensed under the project's MIT license.

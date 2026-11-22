#!/bin/sh
# Check that a main commit may be released as a tag. The release workflow runs
# this before it writes the changelog and tags the release.
#
# usage: verify.sh vX.Y.Z COMMIT   (needs full history, origin/main, and gh)
set -eu

fail() { printf 'verify: %s\n' "$*" >&2; exit 1; }
[ "$#" -eq 2 ] || fail 'usage: .github/release/verify.sh vX.Y.Z COMMIT'
tag=$1
commit=$2

printf '%s\n' "$tag" | LC_ALL=C grep -Eq '^v(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)$' ||
    fail "expected a stable version such as v1.2.3 without leading zeros: $tag"
printf '%s\n' "$commit" | LC_ALL=C grep -Eq '^[0-9a-f]{40}$' || fail "expected a full commit SHA: $commit"
git merge-base --is-ancestor "$commit" origin/main || fail "$commit is not on main"
git rev-parse -q --verify "refs/tags/$tag" >/dev/null && fail "$tag already exists"

result=$(gh run list --workflow ci.yml --branch main --event push --commit "$commit" \
    --json status,conclusion --jq '.[0] | "\(.status) \(.conclusion)"')
[ "$result" = 'completed success' ] || fail "main CI for $commit is '${result:-not found}'; it must pass first"

printf '%s at %s is ready to release.\n' "$tag" "$commit"

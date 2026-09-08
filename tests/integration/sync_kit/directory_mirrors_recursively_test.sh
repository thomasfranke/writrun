#!/usr/bin/env bash
# Sources the harness directly: the sync needs a directory tree, not a
# git repository.
. "$(dirname "$0")/../../harness.sh"

SYNC="$REPO_ROOT/scripts/sync_template.sh"

# A listed directory mirrors whole: nested files arrive, and a file that
# left the root leaves the template — the copy is replaced, not merged.
WORK=$(mktemp -d); cd "$WORK" || exit 1
mkdir -p a-dir/nested template/a-dir
printf 'kept\n' > a-dir/nested/kept.txt
printf 'stale — gone from the root\n' > template/a-dir/stale.txt
printf 'a-dir\n' > mirrors.txt

check "a directory syncs whole" 0 "synced a-dir" -- bash "$SYNC" mirrors.txt
if diff -r -q a-dir template/a-dir >/dev/null 2>&1 \
    && [ ! -e template/a-dir/stale.txt ]; then
  echo "ok    nested files arrive and stale ones leave"; pass=$((pass + 1))
else
  echo "FAIL  nested files arrive and stale ones leave"
  diff -r -q a-dir template/a-dir 2>&1 | sed 's/^/      | /'
  fail=$((fail + 1))
fi

finish

#!/usr/bin/env bash
# Sources the harness directly: the sync needs a directory tree, not a
# git repository.
. "$(dirname "$0")/../../harness.sh"

SYNC="$REPO_ROOT/scripts/sync_template.sh"

# Hand-editing template/ is never the fix — the sync is the one writer,
# and a drifted copy is overwritten back to the root's bytes.
WORK=$(mktemp -d); cd "$WORK" || exit 1
mkdir -p template
printf 'a-file.txt\n' > mirrors.txt
printf 'root content\n' > a-file.txt
printf 'a hand edit\n' > template/a-file.txt

check "the sync runs clean" 0 "synced a-file.txt" -- bash "$SYNC" mirrors.txt
if diff -q a-file.txt template/a-file.txt >/dev/null 2>&1; then
  echo "ok    a drifted mirror is overwritten from the root"; pass=$((pass + 1))
else
  echo "FAIL  a drifted mirror is overwritten from the root"; fail=$((fail + 1))
fi

finish

#!/usr/bin/env bash
# Sources the harness directly: the sync needs a directory tree, not a
# git repository.
. "$(dirname "$0")/../../harness.sh"

SYNC="$REPO_ROOT/scripts/sync_template.sh"

WORK=$(mktemp -d); cd "$WORK" || exit 1
mkdir -p template
printf 'a-file.txt\n' > mirrors.txt
printf 'root content\n' > a-file.txt

check "a listed file lands in template/" 0 "synced a-file.txt" \
  -- bash "$SYNC" mirrors.txt
if diff -q a-file.txt template/a-file.txt >/dev/null 2>&1; then
  echo "ok    the copy is byte-identical"; pass=$((pass + 1))
else
  echo "FAIL  the copy is byte-identical"; fail=$((fail + 1))
fi

finish

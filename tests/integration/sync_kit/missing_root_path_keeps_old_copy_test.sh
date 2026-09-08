#!/usr/bin/env bash
# Sources the harness directly: the sync needs a directory tree, not a
# git repository.
. "$(dirname "$0")/../../harness.sh"

SYNC="$REPO_ROOT/scripts/sync_template.sh"

# A path in the list but gone from the root is a named error — and the
# stale template copy survives. The old inline recipe deleted it and
# still printed "synced": the silent lie this case exists to reject.
WORK=$(mktemp -d); cd "$WORK" || exit 1
mkdir -p template
printf 'gone.txt\nstill-here.txt\n' > mirrors.txt
printf 'the last remaining copy\n' > template/gone.txt
printf 'fine\n' > still-here.txt

check "a missing root path is a named error" 1 "MISSING: 'gone.txt'" \
  -- bash "$SYNC" mirrors.txt
if [ -f template/gone.txt ]; then
  echo "ok    the stale copy is not destroyed"; pass=$((pass + 1))
else
  echo "FAIL  the stale copy is not destroyed"; fail=$((fail + 1))
fi
if diff -q still-here.txt template/still-here.txt >/dev/null 2>&1; then
  echo "ok    the rest of the list still syncs"; pass=$((pass + 1))
else
  echo "FAIL  the rest of the list still syncs"; fail=$((fail + 1))
fi

finish

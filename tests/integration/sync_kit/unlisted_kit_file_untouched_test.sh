#!/usr/bin/env bash
# Sources the harness directly: the sync needs a directory tree, not a
# git repository.
. "$(dirname "$0")/../../harness.sh"

SYNC="$REPO_ROOT/scripts/sync_kit.sh"

# The list is the single source of what ships — kit-only files
# (WRITRUN.md, the skeletons) are not in it and the sync never touches
# them.
WORK=$(mktemp -d); cd "$WORK" || exit 1
mkdir -p kit
printf 'a-file.txt\n' > mirrors.txt
printf 'root content\n' > a-file.txt
printf 'kit-only guide\n' > kit/WRITRUN.md

check "the sync runs clean" 0 "synced a-file.txt" -- bash "$SYNC" mirrors.txt
if [ "$(cat kit/WRITRUN.md)" = "template-only guide" ]; then
  echo "ok    an unlisted template file is untouched"; pass=$((pass + 1))
else
  echo "FAIL  an unlisted template file is untouched"; fail=$((fail + 1))
fi

finish

#!/usr/bin/env bash
# Sources the harness directly: the sync needs a directory tree, not a
# git repository.
. "$(dirname "$0")/../../harness.sh"

SYNC="$REPO_ROOT/scripts/sync_template.sh"

# Blank lines in the mirror list are formatting, not paths.
WORK=$(mktemp -d); cd "$WORK" || exit 1
mkdir -p template
printf 'a-file.txt\n\n\n' > mirrors.txt
printf 'root content\n' > a-file.txt

check "blank list lines are skipped" 0 "synced a-file.txt" \
  -- bash "$SYNC" mirrors.txt

finish

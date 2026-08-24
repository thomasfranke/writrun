#!/usr/bin/env bash
. "$(dirname "$0")/../../mirror_lib.sh"

# A task file the patch cannot yield an id and title from is named and
# skipped — never mirrored as a half-parsed guess.
setup_forge
pr_file added "work/tasks/task-001.md" <<'EOF'
not front-matter at all
EOF
check "an unparseable task is named and skipped" 0 \
  "Could not parse work/tasks/task-001.md; skipping." \
  -- bash "$MIRROR_ISSUES" o/r 7
forge_not_told "nothing is created for it" \
  "POST repos/o/r/issues -f title="

finish

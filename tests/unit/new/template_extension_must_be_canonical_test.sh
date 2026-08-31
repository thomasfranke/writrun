#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

# An extension the canonical form would reject at the merge is refused
# where it is born — generating a file check_front_matter would fail is
# handing the failure forward.
setup
mkdir -p .writrun/conventions/templates
cat > .writrun/conventions/templates/task.md <<'EOF'
---
owner: "quoted value"
---

# {{title}}
EOF
check "a non-canonical extension is refused" 3 "is quoted" \
  -- bash "$NEW_SH" task "Quoted" --origin rule
if ! ls work/tasks/task-*.md >/dev/null 2>&1; then
  echo "ok    the refusal leaves no half-written file"; pass=$((pass + 1))
else
  echo "FAIL  the refusal leaves no half-written file"; fail=$((fail + 1))
fi

finish

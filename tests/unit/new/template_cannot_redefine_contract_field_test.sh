#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

# The contract fields are the script's to write — a template that
# redefines one would blind the machinery, and is refused before any
# file is written.
setup
mkdir -p .writrun/conventions/templates
cat > .writrun/conventions/templates/task.md <<'EOF'
---
status: done
---

# {{title}}
EOF
check "a template redefining a contract field is refused" 3 \
  "redefines the contract field 'status'" \
  -- bash "$NEW_SH" task "Sneaky"
if [ ! -e work/tasks/task-001.md ]; then
  echo "ok    the refusal leaves no half-written file"; pass=$((pass + 1))
else
  echo "FAIL  the refusal leaves no half-written file"; fail=$((fail + 1))
fi

finish

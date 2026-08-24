#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

# Layer 2: no project template, but the shipped .writrun default exists —
# it wins over the built-in skeleton.
setup
mkdir -p .writrun/templates
printf '# {{title}}\n\nShipped shape.\n' > .writrun/templates/task.md
bash "$NEW_SH" task "Layered" >/dev/null 2>&1
if grep -q '^Shipped shape.$' work/tasks/task-001.md; then
  echo "ok    the shipped .writrun template is the fallback layer"; pass=$((pass + 1))
else
  echo "FAIL  the shipped .writrun template is the fallback layer"
  cat work/tasks/task-001.md | sed 's/^/      | /'
  fail=$((fail + 1))
fi

finish

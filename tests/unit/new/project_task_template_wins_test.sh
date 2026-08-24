#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

setup
mkdir -p .writrun/conventions/templates
printf '# {{title}}\n\nOur shape. Id was {{id}}.\n' > .writrun/conventions/templates/task.md
bash "$NEW_SH" task "Custom shaped" >/dev/null 2>&1
if grep -q '^Our shape. Id was task-001.$' work/tasks/task-001.md &&
   grep -q '^# Custom shaped$' work/tasks/task-001.md &&
   grep -q '^status: pending$' work/tasks/task-001.md; then
  echo "ok    a project task template wins over the built-in body"; pass=$((pass + 1))
else
  echo "FAIL  a project task template wins over the built-in body"
  cat work/tasks/task-001.md | sed 's/^/      | /'
  fail=$((fail + 1))
fi

finish

#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

setup
mkdir -p .writrun/conventions/templates
printf '# {{title}}\n\nOur shape. Id was {{id}}.\n' > .writrun/conventions/templates/task.md
bash "$NEW_SH" task "Custom shaped" >/dev/null 2>&1
if grep -q '^Our shape. Id was task-0001.$' work/tasks/task-0001-custom-shaped.md &&
   grep -q '^# Custom shaped$' work/tasks/task-0001-custom-shaped.md &&
   grep -q '^status: backlog$' work/tasks/task-0001-custom-shaped.md; then
  echo "ok    a project task template wins over the built-in body"; pass=$((pass + 1))
else
  echo "FAIL  a project task template wins over the built-in body"
  cat work/tasks/task-0001-custom-shaped.md | sed 's/^/      | /'
  fail=$((fail + 1))
fi

finish

#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

setup
mkdir -p .writrun/templates .writrun/conventions/templates
printf 'Shipped shape.\n' > .writrun/templates/task.md
printf 'Project shape.\n' > .writrun/conventions/templates/task.md
bash "$NEW_SH" task "Order" >/dev/null 2>&1
if grep -q '^Project shape.$' work/tasks/task-0001-order.md &&
   ! grep -q 'Shipped shape' work/tasks/task-0001-order.md; then
  echo "ok    the project template beats the shipped default"; pass=$((pass + 1))
else
  echo "FAIL  the project template beats the shipped default"
  cat work/tasks/task-0001-order.md | sed 's/^/      | /'
  fail=$((fail + 1))
fi

finish

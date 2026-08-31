#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

setup
bash "$NEW_SH" task "Flagged" --origin rule --priority low \
  --depends-on task-001,task-002 \
  --doc-ref product/chapter.md#scope \
  --milestone v0.1 >/dev/null 2>&1
if [ -f work/tasks/task-0001-flagged.md ] &&
   grep -q '^priority: low$'                        work/tasks/task-0001-flagged.md &&
   grep -q '^depends_on: \[task-001, task-002\]$'   work/tasks/task-0001-flagged.md &&
   grep -q '^doc_ref: product/chapter.md#scope$'    work/tasks/task-0001-flagged.md &&
   grep -q '^milestone: v0.1$'                      work/tasks/task-0001-flagged.md; then
  echo "ok    every flag lands in the generated front-matter"; pass=$((pass + 1))
else
  echo "FAIL  every flag lands in the generated front-matter"
  sed -n '1,12p' work/tasks/task-0001-flagged.md 2>/dev/null | sed 's/^/      | /'
  fail=$((fail + 1))
fi

finish

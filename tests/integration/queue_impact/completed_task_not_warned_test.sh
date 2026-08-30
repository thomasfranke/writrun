#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

setup
task_file task-001 completed "" 2026-08-22
sed -i.bak 's|^doc_ref: null$|doc_ref: product/chapter.md#scope|' work/tasks/task-001.md
rm -f work/tasks/task-001.md.bak
commit_all
git checkout -q main; git merge -q feature; git checkout -q feature
printf 'amended rule\n' >> docs/product/chapter.md
commit_all
check "a completed task's reference raises no warning" 0 "No non-completed task" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/check_queue_impact.sh" main...HEAD

finish

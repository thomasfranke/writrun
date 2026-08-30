#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

setup
task_file task-001 pending ""
sed -i.bak 's|^doc_ref: null$|doc_ref: product/chapter.md#scope|' work/tasks/task-001.md
rm -f work/tasks/task-001.md.bak
commit_all
git checkout -q main; git merge -q feature; git checkout -q feature
printf 'amended rule\n' >> docs/product/chapter.md
commit_all
check "editing a doc a pending task references warns and names it" 0 "task-001" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/check_queue_impact.sh" main...HEAD

finish

#!/usr/bin/env bash
. "$(dirname "$0")/../../../pipeline_lib.sh"

# blocked and dropped are a person's; the merge recording moves neither.
setup
git checkout -q main
task_file task-001 blocked spec-001
sed -i.bak 's/^blocked_reason: null$/blocked_reason: waiting/' work/tasks/task-001.md && rm -f work/tasks/*.bak
task_file task-002 dropped spec-002
spec_file spec-001 task-001 draft
spec_file spec-002 task-002 draft
commit_all
spec_file spec-001 task-001 approved
spec_file spec-002 task-002 approved
commit_all

bash "$CI_SCRIPTS/stage-2-pull-requests/record_task_status.sh" HEAD~1...HEAD >/dev/null
grep -qx "status: blocked" work/tasks/task-001.md \
  && { echo "ok    blocked stands"; pass=$((pass+1)); } \
  || { echo "FAIL  blocked stands"; fail=$((fail+1)); }
grep -qx "status: dropped" work/tasks/task-002.md \
  && { echo "ok    dropped stands"; pass=$((pass+1)); } \
  || { echo "FAIL  dropped stands"; fail=$((fail+1)); }

finish

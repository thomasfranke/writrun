#!/usr/bin/env bash
. "$(dirname "$0")/../../../pipeline_lib.sh"

# The bug the amendment flow surfaced live: a merge that merely touches
# an in-flight task's spec — an amendment landing while the work rides
# another, still-open pull request — must not land the task. Pulled
# back to ready, it would read as free while somebody's PR is open; the
# in-flight state belongs to the task's own pull request's events.
setup
git checkout -q main
task_file task-001 in-progress spec-001 null somebody
spec_file spec-001 task-001 approved
commit_all
# The amendment: the spec re-drafted and (post-merge) re-approved — the
# range touches the spec, and only the spec.
spec_file spec-001 task-001 approved "product/chapter.md"
commit_all

bash "$CI_SCRIPTS/stage-2-pull-requests/record_task_status.sh" HEAD~1...HEAD > "$WORK/out" 2>&1
if grep -qx "status: in-progress" work/tasks/task-001.md; then
  echo "ok    an amendment merge leaves the flight alone"; pass=$((pass+1))
else
  echo "FAIL  an amendment merge leaves the flight alone"
  grep -E '^(status|taken_by):' work/tasks/task-001.md | sed 's/^/      | /'
  fail=$((fail+1))
fi
if grep -qx "taken_by: somebody" work/tasks/task-001.md; then
  echo "ok    and the holder keeps the task"; pass=$((pass+1))
else
  echo "FAIL  and the holder keeps the task"; fail=$((fail+1))
fi

# Carried, the same shape lands — the difference is whose work merged.
bash "$CI_SCRIPTS/stage-2-pull-requests/record_task_status.sh" HEAD~1...HEAD task-001 > "$WORK/out" 2>&1
if grep -qx "status: ready" work/tasks/task-001.md; then
  echo "ok    the task's own merge still lands it"; pass=$((pass+1))
else
  echo "FAIL  the task's own merge still lands it"; fail=$((fail+1))
fi

finish

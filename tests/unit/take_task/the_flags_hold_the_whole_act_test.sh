#!/usr/bin/env bash
# `auto_push` and `auto_pr` gate the action and never the work: with
# either false the script composes the whole thing — branch, title, body
# — puts nothing on the forge and nothing in the repository, and names
# the rerun that performs exactly what it printed.
. "$(dirname "$0")/../../pipeline_lib.sh"

flags() {
  settings_file <<JSON
{
  "stage": 2,
  "stage_1": {
    "decisions_style": "per-subsystem",
    "product_layout": "by-concept",
    "provenance_ledger": false,
    "spec_required": "when-warranted"
  },
  "stage_2": {
    "agent_coauthor": true,
    "auto_commit": true,
    "auto_pr": $2,
    "auto_push": $1,
    "pr_title_style": "conventional"
  }
}
JSON
}

take_setup
flags false true
task_file task-001 ready "spec-001"
spec_file spec-001 task-001 approved
commit_all
publish_main
check "auto_push false composes and waits" 2 "auto_push is false" \
  -- bash "$TAKE_TASK" task-001 --title "feat(ci): take it" --slug mirror-lag
check "and prints the branch it would cut" 2 "branch: task/0001-mirror-lag" \
  -- bash "$TAKE_TASK" task-001 --title "feat(ci): take it" --slug mirror-lag
check "and the title it would open under" 2 "title:  \[TASK-0001\] feat(ci): take it" \
  -- bash "$TAKE_TASK" task-001 --title "feat(ci): take it" --slug mirror-lag
check "and the body, spec named" 2 "Implements spec-001." \
  -- bash "$TAKE_TASK" task-001 --title "feat(ci): take it" --slug mirror-lag
check "and names the rerun that performs it" 2 "confirm" \
  -- bash "$TAKE_TASK" task-001 --title "feat(ci): take it" --slug mirror-lag
no_branch_cut "nothing was cut" "task/0001-mirror-lag"
forge_untouched "and the forge was never called"

take_setup
flags true false
task_file task-001 ready ""
commit_all
publish_main
check "auto_pr false holds the push too" 2 "auto_pr is false" \
  -- bash "$TAKE_TASK" task-001 --title "feat(ci): take it" --slug mirror-lag
no_branch_cut "and nothing was cut" "task/0001-mirror-lag"
forge_untouched "and the forge was never called"

take_setup
flags false false
task_file task-001 ready ""
commit_all
publish_main
check "--confirm performs the printed act" 0 "Took task-001" \
  -- bash "$TAKE_TASK" task-001 --title "feat(ci): take it" --slug mirror-lag --confirm
if git -C "$WORK/origin.git" rev-parse --verify --quiet refs/heads/task/0001-mirror-lag >/dev/null; then
  echo "ok    and the branch reached the remote"; pass=$((pass + 1))
else
  echo "FAIL  and the branch reached the remote"; fail=$((fail + 1))
fi

finish

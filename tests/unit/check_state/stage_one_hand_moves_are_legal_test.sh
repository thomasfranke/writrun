#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

# Below Stage 2 no machinery exists to own the status line, so hand
# moves are the contract, not a violation — rules E and F gate on the
# stage setting.
setup
task_file task-001 ready spec-001
spec_file spec-001 task-001 approved
settings_file <<'JSON'
{
  "stage": 1,
  "pr_title_style": "conventional"
}
JSON
commit_all
git checkout -q main; git merge -q feature; git checkout -q feature
task_file task-001 in-progress spec-001
commit_all
check "at stage 1 a hand move between working states passes" 0 "OK" \
  -- bash "$CHECK_STATE" main...HEAD

finish

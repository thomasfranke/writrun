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
  "stage_1": {
    "spec_required": "when-warranted",
    "decisions_style": "per-subsystem",
    "product_layout": "by-concept"
  },
  "stage_2": {
    "auto_commit": true,
    "credit_ai": true,
    "auto_pr": true,
    "pr_title_style": "conventional"
  }
}
JSON
commit_all
git checkout -q main; git merge -q feature; git checkout -q feature
task_file task-001 in-progress spec-001
commit_all
check "at stage 1 a hand move between working states passes" 0 "OK" \
  -- bash "$CHECK_STATE" main...HEAD

finish

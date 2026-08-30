#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

# A task the diff creates is not exempt from the single writer: it
# enters as backlog (or blocked), with no holder and no
# completed-with-draft-specs shortcut.
setup
task_file task-001 in-review spec-001 null somebody
spec_file spec-001 task-001 approved
commit_all
check "born in flight with a holder is rejected" 1 "enters the tree already 'in-review'" \
  -- bash "$CHECK_STATE" main...HEAD

setup
task_file task-001 backlog spec-001 2026-08-22T00:00:00Z
spec_file spec-001 task-001 approved
commit_all
check "born with its date but a spec unimplemented is rejected" 1 "INCONSISTENT" \
  -- bash "$CHECK_STATE" main...HEAD

setup
task_file task-001 backlog spec-001
spec_file spec-001 task-001 draft
commit_all
check "born backlog is the ordinary birth" 0 "OK" \
  -- bash "$CHECK_STATE" main...HEAD

finish

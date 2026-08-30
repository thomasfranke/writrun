#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

# The skeleton's "- none — no behaviour change" bullets carry no backticked
# path and must not be extracted as a promise (say, as "docs/none").
setup
task_file task-001 ready spec-001
spec_file spec-001 task-001 approved
printf 'note\n' >> work/tasks/task-001.md
commit_all
check "a 'none' bullet is not a promised path" 0 "OK" \
  -- bash "$CHECK_DELTAS" spec-001 main...HEAD

finish

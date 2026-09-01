#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

# Partial authorization is not authorization: a task with several specs is
# suspended by any one of them, and each half of the union finds a
# different one.
setup
task_file task-0007 in-progress "spec-0009, spec-0010" "" dana
spec_file spec-0009 task-0007 draft
spec_file spec-0010 task-0007 approved
export WRITRUN_PR_LIST="$(printf '7\ttask/0007-thing\tdana\n9\tqueue/amend-the-promise\tdana')"
export WRITRUN_PR_FILES="$(printf '9\twork/specs/spec-0010.md')"
out=$(bash "$LIST_TASKS" 2>&1)
if printf '%s' "$out" | grep -q "spec-0009 is draft here" &&
   printf '%s' "$out" | grep -q "spec-0010 is amended by #9"; then
  echo "ok    both halves of the union are named in one line"; pass=$((pass + 1))
else
  echo "FAIL  both halves of the union are named in one line"
  printf '%s\n' "$out" | sed 's/^/      | /'
  fail=$((fail + 1))
fi

finish

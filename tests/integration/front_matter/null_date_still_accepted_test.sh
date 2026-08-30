#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

# Nullability is unchanged by the shape. `completed` is a person's to
# write when the work is finished, and until then the honest value is
# `null` — not a timestamp invented to satisfy a checker.
setup
task_file task-001 ready spec-001
spec_file spec-001 task-001 draft
check "a null in a nullable date field is accepted" 0 "all canonical" \
  -- bash "$CHECK_FRONT_MATTER"
if grep -q '^completed: null$' work/tasks/task-001.md; then
  echo "ok    and the field really was null"; pass=$((pass + 1))
else
  echo "FAIL  and the field really was null"; fail=$((fail + 1))
fi

finish

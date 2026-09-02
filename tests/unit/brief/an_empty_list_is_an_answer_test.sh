#!/usr/bin/env bash
# No spec and no doc_ref is a complete brief for a task whose body is the
# whole request — an empty list is an answer, not an error, and the
# divider says which of the two the reader is looking at.
. "$(dirname "$0")/../../pipeline_lib.sh"

setup
task_file task-001 ready ""

check "an empty spec_ref says so"   0 "spec_ref: none" -- bash "$BRIEF" task-001
check "a null doc_ref says so"      0 "doc_ref: none"  -- bash "$BRIEF" task-001
check "and the brief is complete"   0 "Test task task-001" -- bash "$BRIEF" task-001

finish

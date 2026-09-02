#!/usr/bin/env bash
# `0034` is how every queue file and every [TASK-NNNN] tag spells an id,
# so it is the spelling a person retypes. It has to name the same file
# `34` and `task-0034` do — a gate that refuses the spelling the queue
# itself uses reads as a missing task.
. "$(dirname "$0")/../../pipeline_lib.sh"

setup
task_file task-001 backlog ""
commit_all

for id in 1 001 0001 task-001 task-0001; do
  check "preflight resolves '${id}'" 0 "task-001 has no completed date" -- bash "$PREFLIGHT" "$id"
done

# The refusal is still a refusal: an id that names nothing is preflight's
# own failure, and it exits 4 so no caller mistakes it for a stage's code.
check "and an id naming nothing is still exit 4" 4 "resolves to no file" -- bash "$PREFLIGHT" 0099

finish

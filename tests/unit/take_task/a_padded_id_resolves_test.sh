#!/usr/bin/env bash
# The taking act reads ids through the same resolver, and owes the same
# answer: the padded spelling the queue writes must name the file the
# bare number does, or a take refuses work that is sitting right there.
. "$(dirname "$0")/../../pipeline_lib.sh"

take_setup
# Deliberately ineligible: an id that resolved is judged on its status,
# an id that did not is named as unresolvable, and the two refusals are
# told apart by which one is printed. Nothing is created either way, so
# every spelling below is read against the same repository.
task_file task-001 backlog ""
commit_all
publish_main

for id in 1 001 0001 task-001 task-0001; do
  check "take resolves '${id}'" 1 "task-001 is 'backlog'" \
    -- bash "$TAKE_TASK" "$id" --title "feat(ci): take it" --slug mirror-lag --confirm
done
check "and one that names nothing is refused as that" 1 "resolves '0099'" \
  -- bash "$TAKE_TASK" 0099 --title "feat(ci): take it" --slug mirror-lag
no_branch_cut "none of them cut a branch" "task/0001-mirror-lag"

finish

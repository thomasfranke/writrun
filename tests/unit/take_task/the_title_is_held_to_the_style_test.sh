#!/usr/bin/env bash
# The summary is the agent's to write and the style is the adopter's to
# declare. Refusing here costs a rerun; refusing at the door costs a pull
# request already open under a title the project said it would not have.
. "$(dirname "$0")/../../pipeline_lib.sh"

take_setup
task_file task-001 ready ""
commit_all
publish_main

check "no title at all is refused" 1 "title is required" \
  -- bash "$TAKE_TASK" task-001
check "and the refusal shows a valid example" 1 "feat(ci): debounce" \
  -- bash "$TAKE_TASK" task-001
check "the other style's title is refused" 1 "does not read as the declared 'conventional'" \
  -- bash "$TAKE_TASK" task-001 --title "[Feat][Ci] Take it"
check "a type outside the vocabulary is refused" 1 "outside the vocabulary" \
  -- bash "$TAKE_TASK" task-001 --title "wip(ci): take it"
check "a scope outside the vocabulary is refused" 1 "outside the vocabulary" \
  -- bash "$TAKE_TASK" task-001 --title "feat(banana): take it"
no_branch_cut "and none of them cut a branch" "task/0001-test-task-task"

take_setup
settings_file <<'JSON'
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
    "auto_pr": true,
    "auto_push": true,
    "pr_title_style": "bracketed"
  }
}
JSON
task_file task-001 ready ""
commit_all
publish_main
check "the declared style is the one applied" 0 "Took task-001" \
  -- bash "$TAKE_TASK" task-001 --title "[Feat][Ci] Take it" --slug mirror-lag
check "and the tag leads the title" 0 "" -- grep -q 'pr create .*--title \[TASK-0001\] \[Feat\]\[Ci\] Take it' "$FORGE_LOG"

finish

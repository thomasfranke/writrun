#!/usr/bin/env bash
# An option given without its value is a refusal, and — the point of the
# case — a *prompt* one. `shift 2` with a single word left shifts nothing
# and only reports it, so the loop that shrugged the report off read the
# same word forever: the take hung instead of failing, with no output to
# say why. Every case here runs under a deadline for that reason.
. "$(dirname "$0")/../../pipeline_lib.sh"

take_setup
task_file task-001 ready ""
commit_all
publish_main

check "a trailing --title is refused, not looped on" 1 "--title needs a summary" \
  -- bounded 10 bash "$TAKE_TASK" task-001 --title
check "a trailing --slug too" 1 "--slug needs words" \
  -- bounded 10 bash "$TAKE_TASK" task-001 --slug
check "and a trailing --coauthor, which parses the same way" 1 "--coauthor needs a name" \
  -- bounded 10 bash "$TAKE_TASK" task-001 --title "feat(ci): take it" --coauthor
check "and the flags after it are not lost" 1 "--slug needs words" \
  -- bounded 10 bash "$TAKE_TASK" task-001 --title "feat(ci): take it" --slug
no_branch_cut "no branch came out of any of them" "task/0001-mirror-lag"

# The value may be empty — that is a title the style refuses, which is a
# different refusal, and it must still be the one reported.
check "an empty --title is the missing-title refusal" 1 "--title is required" \
  -- bounded 10 bash "$TAKE_TASK" task-001 --title "" --slug mirror-lag

finish

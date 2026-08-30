#!/usr/bin/env bash
. "$(dirname "$0")/../../mirror_lib.sh"

# A body with no ownership line at all: nothing in this machinery wrote
# it, so nobody is working it. Unowned by construction, and adopting is
# the only move that gets the task a mirror it can reach.
setup_forge
added_task task-001 "Mine now"
forge_issue 12 open "writrun:task,status:backlog" "task-001 — Nobody's" none
check "a mirror with no ownership line is adopted" 0 \
  "adopted unowned mirror #12" \
  -- bash "$MIRROR_ISSUES" o/r 7
forge_told "the line is added, naming this PR" "| Introduced by | #7 |"
forge_not_told "no second mirror is created for the same task" \
  "POST repos/o/r/issues -f title="
forge_not_told "no pull request was consulted — there was none to ask about" \
  "repos/o/r/pulls/12"

finish

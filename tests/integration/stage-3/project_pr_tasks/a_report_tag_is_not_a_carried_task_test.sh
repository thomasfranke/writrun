#!/usr/bin/env bash
. "$(dirname "$0")/../../../mirror_lib.sh"

# **A pull request title never carries `[REPORT-NNNN]`** — the bracketed
# tag is how the machinery learns which *tasks* a pull request carries,
# and a report id there would read as work in flight that nobody is
# working (docs/product/stage-3-github-issues/labels.md#the-report-mirror).
# The rule is a rule, so this is what happens when it is broken: the tag
# is not read as a task, and nothing is projected off it.
setup_forge
base_report report-0003 open
forge_report_issue 31 open "writrun:report,status:open" "[REPORT-0003] Something seen"
export PR_HEAD_REF="report/something-seen" PR_TITLE="[REPORT-0003] chore: record it"
check "a report tag names no carried task" 0 "names no task — nothing to project" \
  -- bash "$PROJECT_PR" o/r
forge_untouched "and no mirror of either kind is touched"
unset PR_HEAD_REF PR_TITLE

# And a report id is not silently swapped for the task with that number.
setup_forge
base_task task-0003 ready ""
forge_issue 31 open "writrun:task,status:backlog" "[TASK-0003] A real task"
export PR_HEAD_REF="report/something-seen" PR_TITLE="[REPORT-0003] chore: record it"
check "nor read as the task that shares its number" 0 "nothing to project" \
  -- bash "$PROJECT_PR" o/r
forge_not_told "the task's mirror is left alone" "issues/31/labels"
unset PR_HEAD_REF PR_TITLE

finish

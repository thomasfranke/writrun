#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

# The state no reader built on work/ can see: an issue routed here as an
# observation, waiting for the judgement that it deserves a file. The
# section is the ask, printed where work is picked and above the open
# reports these submissions become
# (docs/technical/selection/visibility.md#a-submission-is-named-before-it-is-a-report).
setup
task_file task-001 ready spec-001
spec_file spec-001 task-001 approved
report_file report-0004 open
export WRITRUN_SUBMITTED_LIST=$'155\tsed -i is not portable\n161\tthe kit ships a stale tag'

check "the marked issue is named by number" 0 "#155" -- bash "$LIST_TASKS"
check "and by its title" 0 "sed -i is not portable" -- bash "$LIST_TASKS"
check "under a heading that says what it is waiting for" 0 \
  "waiting for a report" -- bash "$LIST_TASKS"
check "every marked issue, not just the first" 0 "#161" -- bash "$LIST_TASKS"

# Above `Open reports`, because the two are one ask at two ages — *this
# deserves a file*, then *this file deserves a route*.
check "the section sits above the open reports" 0 "" \
  -- bash -c 'out=$(bash "'"$LIST_TASKS"'"); \
    s=$(printf "%s" "$out" | grep -n "^Submitted" | cut -d: -f1); \
    o=$(printf "%s" "$out" | grep -n "^Open reports" | cut -d: -f1); \
    [ -n "$s" ] && [ -n "$o" ] && [ "$s" -lt "$o" ]'

finish

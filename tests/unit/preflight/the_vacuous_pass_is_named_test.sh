#!/usr/bin/env bash
# A run made before the completion edits passes the state gate by having
# nothing to judge, and the delta stage by having no implemented spec to
# check. Neither silence is a green light, so both are said out loud.
. "$(dirname "$0")/../../pipeline_lib.sh"

setup
git checkout -qb task/0001-mirror-lag
task_file task-001 backlog ""
commit_all

check "the id is inferred from the branch" 0 "task-001 has no completed date" -- bash "$PREFLIGHT"
check "and the run says it stands for nothing yet" 0 "precedes the completion edits" -- bash "$PREFLIGHT"
check "the delta stage says not applicable" 0 "deltas not applicable" -- bash "$PREFLIGHT"
check "and the summary names no spec" 0 "deltas checked: none" -- bash "$PREFLIGHT"

# A comma list widens the warning to every task the change carries.
setup
task_file task-001 backlog ""
task_file task-002 backlog ""
commit_all
check "a comma list names the first" 0 "task-001 has no completed date" -- bash "$PREFLIGHT" task-001,task-002
check "and the second" 0 "task-002 has no completed date" -- bash "$PREFLIGHT" task-001,task-002

# A branch carrying no task marker is not an error: the sweep, the delta
# line and the state read all still have work to do.
setup
git checkout -qb report/mirror-lag
task_file task-001 backlog ""
commit_all
check "a branch with no task marker still runs" 0 "PREFLIGHT OK" -- bash "$PREFLIGHT"
refute "and warns about nothing" "has no completed date" -- bash "$PREFLIGHT"

finish

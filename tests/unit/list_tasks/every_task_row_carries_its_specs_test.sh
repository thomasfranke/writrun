#!/usr/bin/env bash
# Every task row carries the specs the lister resolved to place it, and
# their statuses, as one token before the row's free text — the fact the
# placement was derived from, which the printf used to drop
# (report-0047, decision 0081).
. "$(dirname "$0")/../../pipeline_lib.sh"

# Available: id, priority, token, title.
setup
task_file task-001 ready spec-001
spec_file spec-001 task-001 approved
check "an available row names its spec and status" 0 \
  "task-001 *medium *spec-001:approved *Test task task-001" -- bash "$LIST_TASKS"
check "and the exit code is untouched" 0 "Available" -- bash "$LIST_TASKS"

# Several specs: comma-joined, in spec_ref order, each with its own
# status — the row says what the placement weighed, not a summary of it.
setup
task_file task-001 ready "spec-002, spec-001"
spec_file spec-001 task-001 implemented
spec_file spec-002 task-001 approved
check "several specs join in spec_ref order" 0 \
  "spec-002:approved,spec-001:implemented" -- bash "$LIST_TASKS"

# No spec at all is a word, not an absence: an empty column and a
# missing one look the same.
setup
task_file task-001 ready ""
check "a task with no spec says so" 0 "task-001 *medium *no-spec *Test task" \
  -- bash "$LIST_TASKS"

# Held back: id, token, reason. The token comes first, so a reason that
# names the spec is still the reason and not the field.
setup
task_file task-001 ready spec-001
spec_file spec-001 task-001 draft
check "a held-back row carries the token before the reason" 1 \
  "task-001 *spec-001:draft *MISMATCH — stored ready but spec-001 is draft" \
  -- bash "$LIST_TASKS"
check "and the exit code still says nothing is available" 1 "Held back" \
  -- bash "$LIST_TASKS"

# The second packer of a held record — a status that is neither ready
# nor backlog takes its own path, and a field added to one packer and
# not the other slides the reason into the token's slot.
setup
task_file task-001 blocked ""
check "a blocked row carries the token before its reason" 1 \
  "task-001 *no-spec *blocked: null" -- bash "$LIST_TASKS"
setup
task_file task-001 blocked spec-001
spec_file spec-001 task-001 draft
check "and names the spec when there is one" 1 \
  "task-001 *spec-001:draft *blocked: null" -- bash "$LIST_TASKS"

# In flight: id, author, token, title.
setup
task_file task-001 ready spec-001
spec_file spec-001 task-001 approved
export WRITRUN_PR_LIST="$(printf '7\ttask/001-thing\tdana')"
check "an in-flight row carries the token after the author" 1 \
  "@dana *spec-001:approved *Test task task-001" -- bash "$LIST_TASKS"
unset WRITRUN_PR_LIST

# Resumable: id, token, title — an in-progress task the forge shows no
# open pull request for.
setup
task_file task-001 in-progress spec-001
spec_file spec-001 task-001 approved
export WRITRUN_PR_LIST=""
check "a resumable row carries the token before its title" 1 \
  "task-001 *spec-001:approved *Test task task-001" -- bash "$LIST_TASKS"
check "and it is still the resume section" 1 "resume before selecting" \
  -- bash "$LIST_TASKS"
unset WRITRUN_PR_LIST

# A spec the queue does not hold is named with the status the placement
# judged it by, so the row cannot say less than the decision behind it.
setup
task_file task-001 ready spec-404
check "a spec the queue lacks is named missing" 1 "spec-404:missing" \
  -- bash "$LIST_TASKS"

# The two sections that are not task rows keep their shape: a report and
# a submission carry no spec and must gain no column.
setup
task_file task-001 ready ""
report_file report-001 open
refute "an open report row gains no token" "no-spec *Test report" -- bash "$LIST_TASKS"
check "and is still named" 0 "report-001" -- bash "$LIST_TASKS"

finish

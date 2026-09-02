#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

# The three directories travel together. A caller naming the first two
# and not the third would read tasks from the tree it named and reports
# from the working directory — the shape check_front_matter.sh's caller
# rule exists to stop.
setup
mkdir -p elsewhere/tasks elsewhere/specs elsewhere/reports
task_file task-001 ready spec-001
spec_file spec-001 task-001 approved
report_file report-0001 open
mv work/tasks/task-001.md elsewhere/tasks/
mv work/specs/spec-001.md elsewhere/specs/
mv work/reports/report-0001.md elsewhere/reports/

check "the named tree's task is read" 0 "task-001" \
  -- bash "$LIST_TASKS" elsewhere/tasks elsewhere/specs elsewhere/reports
check "and so is its report" 0 "report-0001" \
  -- bash "$LIST_TASKS" elsewhere/tasks elsewhere/specs elsewhere/reports

# And with no arguments the default is what it always was.
setup
task_file task-001 ready spec-001
spec_file spec-001 task-001 approved
report_file report-0001 open
check "the default reads work/reports" 0 "report-0001" -- bash "$LIST_TASKS"

finish

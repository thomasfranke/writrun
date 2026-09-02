#!/usr/bin/env bash
. "$(dirname "$0")/../../../pipeline_lib.sh"

# The third kind gets the same three-view scan as the other two: the
# directory, the history, and every open pull request. Recording rides
# any change, so two branches that each note something down are the
# ordinary case here rather than the rare one — which makes the collision
# this check exists for more likely for reports than for tasks, not less.
setup
stub_forge
forge_pr 9 added work/reports/report-0003-theirs.md
report_file report-0003 open
commit_all
check "a report id another open pull request adds is rejected, named" 1 "#9" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/check_unique_ids.sh" main...HEAD o/r 7

# The kinds number independently: report-0003 and task-0003 are two ids,
# not one claimed twice.
setup
stub_forge
forge_pr 9 added work/tasks/task-0003-theirs.md
report_file report-0003 open
commit_all
check "a task's number is not a report's" 0 "No id collides" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/check_unique_ids.sh" main...HEAD o/r 7

# And the base branch is the other claimant, with its own message: the id
# is already an id there, so this change is the one that renumbers.
setup
stub_forge
report_file report-0003 open
commit_all
git checkout -q main; git merge -q feature; git checkout -q feature
# A different filename, the same id — which is the shape a collision
# really takes: the subject slug is not identity, so two files may look
# unlike each other and still claim one number.
cp work/reports/report-0003.md work/reports/report-0003-mine.md
commit_all
check "a report id the base branch holds is rejected" 1 "base branch already holds" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/check_unique_ids.sh" main...HEAD o/r 7

finish

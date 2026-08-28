#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

# Neither number is an id yet — identity begins at the merge — so either
# side could renumber. The one being checked is the one told, and it is
# told *which* pull request it collided with, because that is what makes
# renumbering an obvious next step rather than a guess.
setup
stub_forge
forge_pr 9 added work/tasks/task-0007-theirs.md
task_file task-0007 pending ""
commit_all
check "an id another open pull request adds is rejected, named" 1 "#9" \
  -- bash "$CI_SCRIPTS/check_unique_ids.sh" main...HEAD o/r 7

finish

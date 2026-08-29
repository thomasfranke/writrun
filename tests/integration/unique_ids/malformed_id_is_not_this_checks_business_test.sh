#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

# A filename whose id prefix does not parse is check_front_matter.sh's to
# reject. Re-reporting it here would put two different messages on one
# fault, and neither would be the one that names the fix.
setup
stub_forge
printf -- '---\nid: task-0007\n---\n' > work/tasks/task-seven.md
commit_all
check "a malformed queue filename is left to the canonical check" 0 "adds no queue file" \
  -- bash "$CI_SCRIPTS/pull-requests/check_unique_ids.sh" main...HEAD o/r 7

finish

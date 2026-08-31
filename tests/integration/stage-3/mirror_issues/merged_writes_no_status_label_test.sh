#!/usr/bin/env bash
. "$(dirname "$0")/../../../mirror_lib.sh"

# The defect this pass exists past: readiness was derived from the spec
# statuses in the merged pull request's own patch, where the merge has
# not yet flipped them. Both answers it could give were wrong — `backlog`
# for a spec the merge was about to approve, `ready` for one an admin
# merge left draft — and either overwrote the label the approve workflow
# had just derived from the queue. So the merged path writes none.
setup_forge
export PR_STATE=closed PR_MERGED=true
added_task task-001 "Merged with its spec" spec-001
added_spec spec-001 task-001 draft
forge_issue 12 open "writrun:task,status:proposed" "[TASK-001] Merged with its spec"
check "the merge says whose the label is" 0 \
  "task-001 is in the queue; its label is the projection's" \
  -- bash "$MIRROR_ISSUES" o/r 7
forge_not_told "and writes no label set" "PUT repos/o/r/issues/12/labels"
forge_not_told "and reads no spec status out of the patch" "labels[]=status:backlog"

finish

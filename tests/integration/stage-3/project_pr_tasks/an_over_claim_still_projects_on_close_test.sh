#!/usr/bin/env bash
. "$(dirname "$0")/../../../mirror_lib.sh"

# The sibling of the recorder's own close exemption, one layer up. The
# Stage-2 recording has already released the tasks the close named; this
# pass only restates what the queue now says about them, so it claims
# nothing and the ceiling does not stand in its way. Refusing here turned
# the `reflect` job red and left those mirrors reading `in-progress` over
# a queue that says `ready` — a mirror ahead of the file, which no later
# event comes back to heal (decision 0069; spec-0077).
setup_forge
base_task task-0001 ready ""
base_task task-0009 ready ""
forge_issue 31 open "writrun:task,status:in-progress" "[TASK-0001] The work"
forge_issue 39 open "writrun:task,status:in-progress" "[TASK-0009] The sibling"

export PR_HEAD_REF="task/0001-the-work"
export PR_TITLE="[TASK-0001][TASK-0002][TASK-0003][TASK-0004][TASK-0005][TASK-0006][TASK-0007][TASK-0008][TASK-0009] Retitled after the recording"

check "an over-ceiling close still projects" 0 "A close releases rather than claims" \
  -- bash "$PROJECT_PR" o/r closed
forge_told "and the released task's mirror follows the file" \
  "PUT repos/o/r/issues/31/labels -f labels[]=writrun:task -f labels[]=status:ready"
forge_told "as does the one only the title named" \
  "PUT repos/o/r/issues/39/labels -f labels[]=writrun:task -f labels[]=status:ready"

# The exemption is the close's alone: every other event still refuses the
# same claim whole, and reaches no forge at all.
setup_forge
base_task task-0001 in-progress ""
base_task task-0009 ready ""
forge_issue 31 open "writrun:task,status:in-progress" "[TASK-0001] The work"
check "an opened event over the ceiling projects nothing" 1 "Nothing was projected" \
  -- bash "$PROJECT_PR" o/r opened
forge_untouched "and not one call reaches the forge"

# No event argument at all is the old call shape, and it must keep
# refusing — a caller that forgets to say what happened is not a caller
# claiming a close.
check "an omitted event is not a close" 1 "Nothing was projected" \
  -- bash "$PROJECT_PR" o/r
forge_untouched "and it too reaches no forge"

unset PR_HEAD_REF PR_TITLE

finish

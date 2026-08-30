#!/usr/bin/env bash
. "$(dirname "$0")/../../mirror_lib.sh"

# A label carries its description into every project that adopts this.
# `status:backlog` used to claim "Task exists" on issues where the task
# did not exist yet — the false half is what `status:proposed` takes over,
# so both descriptions have to say what is now true.
setup_forge
added_task task-001 "Add search"
check "the labels are declared at open" 0 "Created issue for task-001" \
  -- bash "$MIRROR_ISSUES" o/r 7
forge_told "proposed is declared, and says it is not in the queue" \
  "-f name=status:proposed -f color=ededed -f description=A pull request proposes this task; it is not in the queue yet"
forge_told "pending no longer claims a task that does not exist" \
  "-f name=status:backlog -f color=fbca04 -f description=In the queue, with a spec it references not yet approved"

finish

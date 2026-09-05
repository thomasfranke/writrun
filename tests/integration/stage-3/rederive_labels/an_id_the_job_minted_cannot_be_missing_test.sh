#!/usr/bin/env bash
. "$(dirname "$0")/../../../mirror_lib.sh"

# Minted and never labelled is the one outcome no later event corrects,
# so the step must not report success on it. The mint step names what it
# answered for, and every one of those has an Issue by construction.
setup_forge
base_task task-0009 ready ""
forge_issue 10 open "writrun:task" "[TASK-0008] Someone else's mirror"
base_task task-0008 ready ""
check "an id the mint answered for and no read finds fails the step" 1 \
  "task-0009: no mirrored Issue, and this job's mint answered for one" \
  -- bash "$REDERIVE_LABELS" o/r task-0008 --minted task-0009
forge_told "and the ids it could answer are answered first" \
  "PUT repos/o/r/issues/10/labels"

# The same id arrives twice — once from the commit range, once from the
# mint. Which list it came from is settled before anything is projected,
# so the earlier arrival cannot make the miss a notice.
setup_forge
base_task task-0009 ready ""
check "an id in scope and minted both is judged as minted" 1 \
  "mirror exists and this pass left it unlabelled" \
  -- bash "$REDERIVE_LABELS" o/r task-0009 --minted task-0009

# A task whose mirror genuinely was never minted is a finding about the
# repository, not a defect in this pass. The empty flag is the caller's
# declaration that it minted nothing, so the miss cannot be staleness —
# the first read is the answer, and no re-read is spent on it.
setup_forge
base_task task-0009 ready ""
check "an id no mint claimed stays the notice it was" 0 \
  "task-0009: no mirrored Issue." \
  -- bash "$REDERIVE_LABELS" o/r task-0009 --minted
forge_told_times "answered from the one read already in hand" 1 \
  "issues?labels=writrun:task"

# No flag at all is the other half of the declared-not-assumed contract:
# a caller that says nothing buys the unconditional re-read, so a minting
# caller wired without the flag wastes seconds and never loses a mirror.
# Pinned so a refactor cannot quietly flip it.
setup_forge
base_task task-0009 ready ""
check "a run given no flag at all still re-reads on a miss" 0 \
  "task-0009: no mirrored Issue." \
  -- bash "$REDERIVE_LABELS" o/r task-0009
forge_told_times "spending the re-reads as it always did" 3 \
  "issues?labels=writrun:task"

finish

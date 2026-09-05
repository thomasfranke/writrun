#!/usr/bin/env bash
. "$(dirname "$0")/../../../mirror_lib.sh"

# The two mirror steps run inside the recording job, under `!cancelled()`,
# so they follow a push that may have been refused — and the runner's
# tree then still carries the commit `main` rejected. A labeller reading
# that tree projects a queue state existing nowhere but the runner.
#
# **Direction is what makes it expensive.** A mirror *behind* the queue is
# faithful and catches up at the next successful recording. One *ahead*
# of it asserts a state `main` refused, and the next recording has no
# reason to revisit a label that already reads what it is about to write.
#
# `AUTHORITY_REF` is what the labeller reads instead. The fixture is a
# real git repository so the ref is a real ref: `origin/main` holds the
# queue as it landed, and the working tree holds the recording that did
# not.

# landed_then_refused — a repository where the authority branch holds one
# state and the tree holds a later one that never reached it.
landed_then_refused() {
  git init -q .
  git symbolic-ref HEAD refs/heads/main
  git config user.email t@e; git config user.name t
  base_task task-0005 backlog ""
  git add -A >/dev/null; git commit -qm landed
  # The ref the push would have moved, standing where it really stands.
  git update-ref refs/remotes/origin/main "$(git rev-parse HEAD)"
  base_task task-0005 ready ""
  git add -A >/dev/null; git commit -qm "the recording that was refused"
}

setup_forge
landed_then_refused
forge_issue 31 open "writrun:task,status:backlog" "[TASK-0005] The work"
AUTHORITY_REF=origin/main \
  check "the label comes from the branch that landed, not the tree" 0 \
  "task-0005 → status:backlog" -- bash "$REDERIVE_LABELS" o/r task-0005
forge_not_told "and the refused state is never written to the mirror" "status:ready"

# The other direction, which is every ordinary run: the push landed, so
# the ref and the tree agree and the labels are exactly today's.
setup_forge
landed_then_refused
git update-ref refs/remotes/origin/main "$(git rev-parse HEAD)"
forge_issue 31 open "writrun:task,status:backlog" "[TASK-0005] The work"
AUTHORITY_REF=origin/main \
  check "a recording that landed labels exactly as it does today" 0 \
  "task-0005 → status:ready" -- bash "$REDERIVE_LABELS" o/r task-0005

# Unset is the working tree, which is what every caller running *from*
# the authority branch already has — project_pr_tasks.sh's path, where
# the two agree by construction.
setup_forge
landed_then_refused
forge_issue 31 open "writrun:task,status:backlog" "[TASK-0005] The work"
check "without the ref the queue is the tree, as before" 0 \
  "task-0005 → status:ready" -- bash "$REDERIVE_LABELS" o/r task-0005

# A ref that cannot be read is not a licence to fall back. Falling back
# is how the mirror gets ahead of the queue, which is the whole fault.
setup_forge
landed_then_refused
forge_issue 31 open "writrun:task,status:backlog" "[TASK-0005] The work"
AUTHORITY_REF=origin/nothing-named-this \
  check "an unreadable authority ref writes no label, loudly" 4 \
  "names no commit this checkout can read" -- bash "$REDERIVE_LABELS" o/r task-0005
forge_not_told "and no label was written from the tree instead" "status:ready"

finish

#!/usr/bin/env bash
# push_recording.sh — lands a composed recording commit on the branch.
#
# Usage: push_recording.sh <branch>
#   Run from the repository root, on a checkout already carrying the
#   recording commit. The caller composes and commits; this script only
#   makes the commit reach the branch.
#
# The loss this closes: two recordings racing to one branch. The push
# is refused because the branch moved under a rebase that predates it,
# so the answer is to read the branch again and push again. Never
# --force and never --force-with-lease, on any attempt: the recording
# is an addition to the branch's history, not a replacement of it, and
# the lease flag is the one that fails on exactly the race being
# survived.
#
# The budget is five attempts, sized by the largest burst practice has
# produced — the five drafts a five-task batch opens seconds apart. The
# worst-placed of five runs can lose four races before its turn. One
# fetch and one push per attempt: the budget belongs to the run, never
# to each obstacle.
#
# A retry is earned, never assumed. The fetch that opens the next
# attempt shows whether the tip left the commit the refused push was
# rebased onto; an unmoved tip means the refusal was never a race — a
# protected branch, a revoked token, a required check — and the run
# fails at once naming the branch as unmoved. Movement is the one
# version-proof fact: git and the forge word their refusals differently
# across versions, so no stderr is read. And no attempt sleeps — every
# retry spent is a sibling's recording landing, so the loop only loses
# while the queue advances.
#
# A conflicting rebase aborts back to the recording commit and fails at
# once: the same commit meets the same conflict, and the tree must not
# be left carrying markers in the queue files the projection reads from
# disk.
#
# Exit codes: 0 the recording is on the branch — a rebase that finds it
# already landed and drops it exits 0 too; 1 it could not be landed (a
# conflict, an unmoved refusal, an exhausted budget); 3 the caller is
# not holding a recording to land.
#
# Portable bash 3.2, POSIX awk/sed — no gawk extensions. See the
# standing rule in docs/technical/decisions/.

set -euo pipefail

BRANCH="${1:?usage: push_recording.sh <branch>}"
BUDGET=5

# --- the caller's half, checked before the remote is touched -----------
#
# A caller that has not committed must hear so, not watch a no-op
# report success — the failure distribution/checks.md says looks
# ordinary. The guard fetches nothing: the remote-tracking ref the
# checkout already carries is the view the caller committed against,
# and the loop's own first pull is the one fetch an attempt pays.
if [ -n "$(git status --porcelain)" ]; then
  echo "the working tree is dirty — commit the recording first; this script only lands one." >&2
  exit 3
fi
# A range git cannot answer is a refusal too: defaulting it would guess
# at the one thing this guard exists to know — the posture take_task.sh
# already takes.
if ! AHEAD=$(git rev-list --count "refs/remotes/origin/${BRANCH}..HEAD" 2>&1); then
  echo "git rev-list --count refs/remotes/origin/${BRANCH}..HEAD failed:" >&2
  printf '%s\n' "$AHEAD" | head -n 3 >&2
  echo "whether HEAD carries a recording is the one thing this script must not guess at." >&2
  exit 3
fi
if [ "$AHEAD" = 0 ]; then
  echo "HEAD is not ahead of origin/${BRANCH} — nothing committed, nothing to land." >&2
  exit 3
fi

# --- the loop: rebase onto the branch as it then stands, then push -----
attempt=0
rebased_onto=""
while [ "$attempt" -lt "$BUDGET" ]; do
  attempt=$((attempt + 1))

  if ! git pull --rebase origin "$BRANCH"; then
    git rebase --abort || true
    echo "rebase onto ${BRANCH} conflicted — aborted back to the recording commit, nothing pushed." >&2
    echo "the same commit meets the same conflict; re-running the job re-derives the write against ${BRANCH} as it then stands." >&2
    exit 1
  fi

  tip=$(git rev-parse FETCH_HEAD)
  if [ -n "$rebased_onto" ] && [ "$tip" = "$rebased_onto" ]; then
    echo "the push was refused and ${BRANCH} is unmoved — that refusal was never a race." >&2
    echo "something else stands in the way: a ruleset on ${BRANCH}, a token without write, a required check." >&2
    exit 1
  fi

  if git push origin "HEAD:${BRANCH}"; then
    echo "recorded on ${BRANCH} (attempt ${attempt} of ${BUDGET})."
    exit 0
  fi
  rebased_onto="$tip"
done

echo "the push to ${BRANCH} was refused on all ${attempt} attempts — the branch outran the budget." >&2
echo "re-running the job re-derives the same write from the same event against ${BRANCH} as it then stands." >&2
exit 1

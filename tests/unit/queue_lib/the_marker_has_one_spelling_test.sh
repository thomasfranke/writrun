#!/usr/bin/env bash
# The draft marker is written down twice, on purpose and with the reason
# recorded: `queue_lib.sh` holds it for the two stage-2 checks that
# source it, and `check_front_matter.sh` carries its own because a skill
# is standalone — it is the one check available at every adoption stage,
# and reaching into scripts/stage-2-pull-requests/ would break that.
#
# Two copies with a reason is a decision. Two copies that drift is a
# chapter that is a draft to one check and a rule to another, which is
# the worst answer available: the front-matter sweep would refuse a
# doc_ref the promise check accepts, over the same file. This repository
# has been bitten by a private clone of a shared helper drifting before —
# queue_lib.sh's own header records it — so the literals are pinned equal
# here rather than trusted to stay so.
. "$(dirname "$0")/../../harness.sh"

QUEUE_LIB="$REPO_ROOT/.writrun/scripts/stage-2-pull-requests/queue_lib.sh"
SKILL="$REPO_ROOT/.writrun/skills/writrun-check-front-matter/check_front_matter.sh"

# Read from the assignment rather than by sourcing: the skill never
# exports the literal, it compares against it inline, so the only thing
# both files can be asked in the same way is what they wrote down.
shared=$(sed -n "s/^QL_DRAFT_MARKER='\(.*\)'$/\1/p" "$QUEUE_LIB")
private=$(sed -n "s/^  \[ \"\$first\" = '\(.*\)' \]$/\1/p" "$SKILL")

if [ -z "$shared" ]; then
  echo "FAIL  queue_lib.sh no longer assigns QL_DRAFT_MARKER at column 0"
  fail=$((fail + 1))
elif [ -z "$private" ]; then
  echo "FAIL  check_front_matter.sh no longer compares a literal marker in doc_declares_draft"
  fail=$((fail + 1))
elif [ "$shared" = "$private" ]; then
  echo "ok    both spellings of the draft marker are '$shared'"
  pass=$((pass + 1))
else
  printf 'FAIL  the draft marker has drifted: queue_lib says %s, the skill says %s\n' \
    "'$shared'" "'$private'"
  fail=$((fail + 1))
fi

finish

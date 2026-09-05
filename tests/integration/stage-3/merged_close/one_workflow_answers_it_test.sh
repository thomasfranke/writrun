#!/usr/bin/env bash
. "$(dirname "$0")/../../../pipeline_lib.sh"

# The settlement is wiring, and wiring lives in YAML — the suite cannot
# observe it by running a script. Three workflows answered
# `pull_request_target: closed`, two of them wrote a mirror's label, and
# the one that won was whichever finished last. A forge offers no
# ordering across workflows; one owner needs none.
setup

APPROVE="$WORKFLOWS/writrun-approve.yml"

stands_down() {   # stands_down <workflow> <job>
  local f="$WORKFLOWS/$1"
  if awk -v job="  $2:" '
      $0 == job { inj = 1; next }
      inj && /^  [a-z]/ { exit }
      inj && /merged != true/ { found = 1 }
      END { exit(found ? 0 : 1) }
    ' "$f"; then
    printf 'ok    %s: %s stands down for a merged close\n' "$1" "$2"
    pass=$((pass + 1))
  else
    printf 'FAIL  %s: %s stands down for a merged close\n' "$1" "$2"
    fail=$((fail + 1))
  fi
}

stands_down writrun-issues.yml mirror
stands_down writrun-progress.yml reflect

# And the owner runs both halves, in the only order that can be right:
# the queue is written and pushed, then the mirror is made to exist, then
# it is labelled from the queue that now holds what the merge decided.
#
# The push is read as the call that lands the recording, not as a raw
# `git push`: the landing is push_recording.sh's since it gained the
# retry, and the order this case is about is unchanged by which of the
# two spells it.
# The call is matched by its path, which the step's comment above it
# does not carry — a bare script name would match both and hand the
# comparison two line numbers.
push=$(grep -n 'scripts/stage-2-pull-requests/push_recording.sh' "$APPROVE" | cut -d: -f1)
mint=$(grep -n 'mirror_issues.sh' "$APPROVE" | cut -d: -f1)
label=$(grep -n 'rederive_labels.sh' "$APPROVE" | cut -d: -f1)

if [ -n "$push" ] && [ -n "$mint" ] && [ -n "$label" ] \
   && [ "$push" -lt "$mint" ] && [ "$mint" -lt "$label" ]; then
  printf 'ok    the owner pushes the queue, then mints, then labels\n'
  pass=$((pass + 1))
else
  printf 'FAIL  the owner pushes the queue, then mints, then labels\n'
  printf '      push=%s mint=%s label=%s\n' "$push" "$mint" "$label"
  fail=$((fail + 1))
fi

# Scope, not the moved set: a task the merge created already resting
# where it belongs writes no `moved` line and still owes a label.
if grep -q 'steps.status.outputs.scope' "$APPROVE"; then
  printf 'ok    the projection is given every task the merge had in scope\n'
  pass=$((pass + 1))
else
  printf 'FAIL  the projection is given every task the merge had in scope\n'
  fail=$((fail + 1))
fi

# Both mirror steps are Stage 3's, so an adopter below that stage reaches
# for no mirror here either.
if [ "$(grep -c "needs.gate.outputs.mirror == 'true'" "$APPROVE")" -eq 2 ]; then
  printf 'ok    both mirror steps are gated on Stage 3\n'; pass=$((pass + 1))
else
  printf 'FAIL  both mirror steps are gated on Stage 3\n'; fail=$((fail + 1))
fi

# And on `!cancelled()`, not the implicit `success()`. The steps follow
# the recording commit, so a refused push or a conflicting rebase would
# otherwise skip them — and with the other two workflows standing down,
# that is the merged close answering nothing at all, with no later event
# to correct it.
if [ "$(grep -c '!cancelled() && needs.gate.outputs.mirror' "$APPROVE")" -eq 2 ]; then
  printf 'ok    a failed recording does not also skip the mirror\n'; pass=$((pass + 1))
else
  printf 'FAIL  a failed recording does not also skip the mirror\n'; fail=$((fail + 1))
fi

# The mint reports what it minted, and the projection is given it: the
# two sets are derived from different sources — the pull request's files
# and a commit range — and a rebase merge is where they part.
if grep -q 'steps.mint.outputs.tasks' "$APPROVE" && grep -q '^        id: mint$' "$APPROVE"; then
  printf 'ok    the projection is also given the set the mint answered\n'
  pass=$((pass + 1))
else
  printf 'FAIL  the projection is also given the set the mint answered\n'
  fail=$((fail + 1))
fi

finish

#!/usr/bin/env bash
. "$(dirname "$0")/../../../mirror_lib.sh"

# The catch-up. A merged pull request creates any mirror still missing
# rather than assuming an earlier event already did — and for a report
# that path is not a rare repair, it is the *ordinary* one every time the
# machinery that mirrors reports ships through a pull request that also
# records one: the open event ran the base branch's script, which had
# never heard of the kind.
#
# It is born `open`, never `proposed`. The merge is what put the report on
# the authority branch, and `open` is the state the mirror exists for.
setup_forge
export PR_STATE=closed PR_MERGED=true
added_report report-0001 "The conventions folder has no scope"
check "a merge mints the report mirror it owes" 0 \
  "Created issue for report-0001 (status:open)" \
  -- bash "$MIRROR_ISSUES" o/r 7
forge_told "born open, and its own kind" \
  "POST repos/o/r/issues -f title=[REPORT-0001] The conventions folder has no scope -f labels[]=writrun:report -f labels[]=status:open"
forge_told "the label is declared with what it means" \
  "-f name=status:open -f color=0e8a16 -f description=Recorded and awaiting triage"
forge_not_told "never proposed — the merge is past that" "labels[]=status:proposed"
forge_not_told "and never closed" "state=closed"

# And it is named on the output the projection reads, so the pass that
# labels next works from what was really minted rather than from a commit
# range — the drift a rebase merge opens for tasks is open for reports too.
setup_forge
export PR_STATE=closed PR_MERGED=true
export GITHUB_OUTPUT="$WORK/gh_output"
: > "$GITHUB_OUTPUT"
added_report report-0001 "The conventions folder has no scope"
bash "$MIRROR_ISSUES" o/r 7 >/dev/null
if grep -qx 'reports=report-0001' "$GITHUB_OUTPUT"; then
  echo "ok    the mint reports what it minted"; pass=$((pass + 1))
else
  echo "FAIL  the mint reports what it minted"
  sed 's/^/      | /' "$GITHUB_OUTPUT"; fail=$((fail + 1))
fi
unset GITHUB_OUTPUT

finish

#!/usr/bin/env bash
. "$(dirname "$0")/../../../mirror_lib.sh"

# report-0031's fourth fault, and the damage it has already done in an
# adopter's tracker. Issue #18 was triaged and closed; a second mint of
# the same id reopened it and rewrote its `Introduced by` row to name a
# pull request that never mentioned the finding the Issue describes. A
# maintainer reading that tracker sees an open item, wrongly attributed,
# and nothing in the run said so.
#
# A reopen is not by itself evidence — a closed-unmerged pull request
# reopening, or a report triaged and untriaged inside one pull request's
# life, both reopen a mirror of the same file. What separates them is the
# title: on a legitimate reopen the mirror still names the same finding,
# and when the id has come back it names a different one.
setup_forge
added_report report-0001 "Something else entirely"
forge_report_issue 18 closed "writrun:report" "[REPORT-0001] Take needs a commit" 17
forge_pr_state 17 closed

check "a reopen onto a different title is named" 0 \
  "names a different finding" \
  -- bash "$MIRROR_ISSUES" o/r 7

# Both titles, and the pull request that introduced the mirror: what a
# maintainer needs to tell a returned id from an edited heading in one
# read. And the rule, because the line is where somebody learns it.
check "the mirror's own title is printed" 0 "titled: Take needs a commit" \
  -- bash "$MIRROR_ISSUES" o/r 7
check "beside the title this diff carries" 0 \
  "this diff carries: Something else entirely" \
  -- bash "$MIRROR_ISSUES" o/r 7
check "and the pull request the mirror came from" 0 "introduced by #17" \
  -- bash "$MIRROR_ISSUES" o/r 7
check "and the rule that was broken" 0 "An id is never reused" \
  -- bash "$MIRROR_ISSUES" o/r 7

# Named, and projected anyway. The mirror is the best-effort write half,
# and a report with no mirror at all is the one state this reconciliation
# may not leave behind — so the reopen still happens and the run still
# exits 0.
forge_told "the mirror is still reopened" \
  "PATCH repos/o/r/issues/18 -f state=open"
forge_told "and still labelled from the file" \
  "PUT repos/o/r/issues/18/labels -f labels[]=writrun:report -f labels[]=status:proposed"

# The adoption line says the state it adopted the mirror in — the other
# half of the evidence, and a fact the line used to omit.
check "the adoption names the state it found" 0 \
  "adopted stale mirror #18, closed" \
  -- bash "$MIRROR_ISSUES" o/r 7

finish

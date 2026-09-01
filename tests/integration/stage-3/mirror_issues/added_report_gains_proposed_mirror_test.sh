#!/usr/bin/env bash
. "$(dirname "$0")/../../../mirror_lib.sh"

# A report recorded on an open pull request is only *proposed* — the pull
# request may still close unmerged and take the mirror with it, so the
# authority branch does not hold it yet. Same structural reason a task's
# mirror has the state; different label vocabulary around it, and its own
# `writrun:report` kind so the two never meet in one filter.
setup_forge
added_report report-0003 "The mirror shows backlog for ready tasks"
check "an added report is mirrored at open" 0 "Created issue for report-0003" \
  -- bash "$MIRROR_ISSUES" o/r 7
forge_told "the mirror is its own kind, titled by the report's tag" \
  "POST repos/o/r/issues -f title=[REPORT-0003] The mirror shows backlog for ready tasks -f labels[]=writrun:report -f labels[]=status:proposed"
forge_told "the body carries this PR's ownership line" \
  "| Introduced by | #7 |"

# Origin is a fact about how a *task* came to exist, and a report is one
# of its two answers — a report has none of its own to project.
forge_not_told "and no origin label is written" "labels[]=origin:"
forge_not_told "nor a task's kind" "labels[]=writrun:task"

finish

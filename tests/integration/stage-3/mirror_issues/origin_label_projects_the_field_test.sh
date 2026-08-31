#!/usr/bin/env bash
. "$(dirname "$0")/../../../mirror_lib.sh"

# Alongside its status label, every mirror carries one `origin:` label
# projecting the task's stored field — so a reader scanning the Issues
# list tells planned rule-work from reported defects without opening
# anything (docs/product/stage-3-github-issues/labels.md).
setup_forge
added_task task-001 "Add search" "" rule
added_task task-002 "Checkout returns 500" "" report
check "both tasks are mirrored" 0 "Created issue for task-002" \
  -- bash "$MIRROR_ISSUES" o/r 7
forge_told "a derived task is labelled origin:rule" \
  "-f labels[]=status:proposed -f labels[]=origin:rule"
forge_told "a reported one is labelled origin:report" \
  "-f labels[]=status:proposed -f labels[]=origin:report"
forge_told "the rule label is declared in documentation blue" \
  "POST repos/o/r/labels -f name=origin:rule -f color=0075ca"
forge_told "and the report label in bug red" \
  "POST repos/o/r/labels -f name=origin:report -f color=d73a4a"

finish

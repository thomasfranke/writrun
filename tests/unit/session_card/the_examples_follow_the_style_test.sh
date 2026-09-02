#!/usr/bin/env bash
# The style is what the queue of open pull requests reads like, so the
# card shows it rather than describing it — one example per kind, in the
# style the project declared.
. "$(dirname "$0")/../../pipeline_lib.sh"

style() {
  settings_file <<JSON
{
  "stage": 2,
  "stage_1": {
    "decisions_style": "per-subsystem",
    "product_layout": "by-concept",
    "provenance_ledger": true,
    "spec_required": "when-warranted"
  },
  "stage_2": {
    "agent_coauthor": true,
    "auto_commit": true,
    "auto_pr": true,
    "auto_push": true,
    "pr_title_style": "$1"
  }
}
JSON
}

setup
style bracketed
check "an implementing title carries the tag then brackets" 0 "\[TASK-0012\]\[Fix\]\[Ci\]" -- bash "$SESSION_CARD"
check "an authoring one carries no tag" 0 "\[Docs\]\[Product\]" -- bash "$SESSION_CARD"
refute "and the other style is not shown" "fix(ci): debounce" -- bash "$SESSION_CARD"

setup
style conventional
check "the conventional example is the grammar" 0 "\[TASK-0012\] fix(ci): debounce" -- bash "$SESSION_CARD"
refute "and the bracketed one is not shown" "\[Fix\]\[Ci\]" -- bash "$SESSION_CARD"

# The subject's grammar is a constant, so it prints whatever the style is.
check "the commit subject constant prints either way" 0 "type(scope): imperative summary" -- bash "$SESSION_CARD"

finish

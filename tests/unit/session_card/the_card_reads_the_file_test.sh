#!/usr/bin/env bash
# The card computes nothing: every value is the settings file's, and a
# value nobody declared is printed as the documented default and marked
# as one — "this is what the project decided" and "this is what nobody
# decided" are different sentences.
. "$(dirname "$0")/../../pipeline_lib.sh"

setup
settings_file <<'JSON'
{
  "stage": 2,
  "stage_1": {
    "decisions_style": "one-file",
    "product_layout": "by-stage",
    "provenance_ledger": false,
    "spec_required": "always"
  },
  "stage_2": {
    "agent_coauthor": false,
    "auto_commit": false,
    "auto_pr": false,
    "auto_push": false,
    "pr_title_style": "bracketed"
  }
}
JSON

check "the declared stage prints, marked declared" 0 "stage: 2 (declared)" -- bash "$SESSION_CARD"
check "a false flag prints as false" 0 "auto_push:         false (declared)" -- bash "$SESSION_CARD"
check "with its operational meaning beside it" 0 "commit without asking" -- bash "$SESSION_CARD"
check "the declarations print too" 0 "spec_required:     always (declared)" -- bash "$SESSION_CARD"
check "and the ledger's false is not a silence" 0 "provenance_ledger: false (declared)" -- bash "$SESSION_CARD"

# Pre-adoption is a state, not an error.
setup
check "no settings file still renders" 0 "stage: 3 (default)" -- bash "$SESSION_CARD"
check "and every default is marked as one" 0 "auto_commit:       true (default)" -- bash "$SESSION_CARD"

finish

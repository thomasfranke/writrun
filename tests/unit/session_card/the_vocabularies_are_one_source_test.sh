#!/usr/bin/env bash
# The vocabularies are values, so the card reads them where every other
# value comes from — settings.json, through read_setting.sh, with the
# origin marked (docs/technical/settings/schema.md#settings). It scraped
# check_observance.sh's own assignment lines while the check carried
# them embedded; a card built by parsing a script states what that
# script happens to say, which is a different claim from what the
# project declared.
. "$(dirname "$0")/../../pipeline_lib.sh"

setup
settings_file <<'JSON'
{
  "stage": 3,
  "stage_1": {
    "decisions_style": "per-subsystem",
    "product_layout": "by-concept",
    "provenance_ledger": false,
    "spec_required": "when-warranted"
  },
  "stage_2": {
    "agent_coauthor": true,
    "auto_commit": true,
    "auto_pr": true,
    "auto_push": true,
    "commit_scopes": "api web",
    "commit_types": "docs feat fix",
    "pr_title_style": "conventional"
  }
}
JSON
check "the types are the project's, and marked declared" 0 "types:   docs feat fix (declared)" \
  -- bash "$SESSION_CARD"
check "and so are the scopes" 0 "scopes:  api web (declared)" \
  -- bash "$SESSION_CARD"

# A vocabulary nobody declared is the documented default, marked as one
# — never a shorter list presented as the project's choice. The card
# does not refuse: absence is a legal state everywhere else in the file,
# and it is one here.
setup
check "an undeclared vocabulary is the default, and says so" 0 "types:   docs feat fix refactor chore (default)" \
  -- bash "$SESSION_CARD"
check "and its scopes are marked the same way" 0 "about product technical tasks specs skills" \
  -- bash "$SESSION_CARD"
check "the card still exits 0 with nothing declared" 0 "" -- bash "$SESSION_CARD"

finish

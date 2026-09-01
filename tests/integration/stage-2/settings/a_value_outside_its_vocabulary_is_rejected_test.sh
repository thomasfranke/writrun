#!/usr/bin/env bash
. "$(dirname "$0")/../../../pipeline_lib.sh"

# A key only an agent reads is still checked for value: an agent reading
# `gherkin` would write titles in a style the project never chose.
setup
settings_file <<'JSON'
{
  "stage": 3,
  "stage_1": {
    "spec_required": "when-warranted",
    "decisions_style": "per-subsystem",
    "product_layout": "by-concept"
  },
  "stage_2": {
    "auto_commit": true,
    "agent_coauthor": true,
    "auto_pr": true,
    "pr_title_style": "gherkin"
  }
}
JSON
check "a style outside the vocabulary is rejected" 1 \
  "pr_title_style 'gherkin' is outside its vocabulary" \
  -- bash "$CHECK_SETTINGS"

settings_file <<'JSON'
{
  "stage": "everything",
  "stage_1": {
    "spec_required": "when-warranted",
    "decisions_style": "per-subsystem",
    "product_layout": "by-concept"
  },
  "stage_2": {
    "auto_commit": true,
    "auto_pr": true,
    "auto_push": true,
    "agent_coauthor": true,
    "pr_title_style": "conventional"
  }
}
JSON
check "and so is a stage outside it" 1 \
  "stage 'everything' is outside its vocabulary" \
  -- bash "$CHECK_SETTINGS"

# The three conduct flags are booleans, and "ask" is not one of them: an
# agent reading anything else would have to guess which side it means.
settings_file <<'JSON'
{
  "stage": 3,
  "stage_1": {
    "spec_required": "when-warranted",
    "decisions_style": "per-subsystem",
    "product_layout": "by-concept"
  },
  "stage_2": {
    "auto_commit": "ask",
    "agent_coauthor": true,
    "auto_pr": true,
    "pr_title_style": "conventional"
  }
}
JSON
check "auto_commit takes true or false and nothing else" 1 \
  "auto_commit 'ask' is outside its vocabulary" \
  -- bash "$CHECK_SETTINGS"

settings_file <<'JSON'
{
  "stage": 3,
  "stage_1": {
    "spec_required": "when-warranted",
    "decisions_style": "per-subsystem",
    "product_layout": "by-concept"
  },
  "stage_2": {
    "auto_commit": true,
    "agent_coauthor": true,
    "auto_pr": 1,
    "pr_title_style": "conventional"
  }
}
JSON
check "and so does auto_pr" 1 "auto_pr '1' is outside its vocabulary" \
  -- bash "$CHECK_SETTINGS"

settings_file <<'JSON'
{
  "stage": 3,
  "stage_1": {
    "spec_required": "when-warranted",
    "decisions_style": "per-subsystem",
    "product_layout": "by-concept"
  },
  "stage_2": {
    "auto_commit": true,
    "agent_coauthor": "no",
    "auto_pr": true,
    "pr_title_style": "conventional"
  }
}
JSON
check "and so does agent_coauthor" 1 "agent_coauthor 'no' is outside its vocabulary" \
  -- bash "$CHECK_SETTINGS"

settings_file <<'JSON'
{
  "stage": 3,
  "stage_1": {
    "spec_required": "when-warranted",
    "decisions_style": "per-subsystem",
    "product_layout": "by-concept"
  },
  "stage_2": {
    "auto_commit": true,
    "auto_pr": true,
    "auto_push": "yes",
    "agent_coauthor": true,
    "pr_title_style": "conventional"
  }
}
JSON
check "and so does auto_push, the third conduct flag" 1 \
  "auto_push 'yes' is outside its vocabulary" \
  -- bash "$CHECK_SETTINGS"

# Both booleans pass, which is the other half of a vocabulary: a check
# that only ever rejected would be indistinguishable from one that
# rejects everything.
settings_file <<'JSON'
{
  "stage": 3,
  "stage_1": {
    "spec_required": "when-warranted",
    "decisions_style": "per-subsystem",
    "product_layout": "by-concept",
    "provenance_ledger": false
  },
  "stage_2": {
    "auto_commit": true,
    "auto_pr": true,
    "auto_push": false,
    "agent_coauthor": true,
    "pr_title_style": "conventional"
  }
}
JSON
check "a gated push is canonical" 0 "is canonical" -- bash "$CHECK_SETTINGS"

# The three declarations gate nothing mechanical — an agent alone reads
# them — and are checked for value all the same, for the same reason:
# a value outside the vocabulary is one an agent would have to guess at.
settings_file <<'JSON'
{
  "stage": 3,
  "stage_1": {
    "spec_required": "sometimes",
    "decisions_style": "per-subsystem",
    "product_layout": "by-concept"
  },
  "stage_2": {
    "auto_commit": true,
    "auto_pr": true,
    "auto_push": true,
    "agent_coauthor": true,
    "pr_title_style": "conventional"
  }
}
JSON
check "spec_required takes always or when-warranted" 1 \
  "spec_required 'sometimes' is outside its vocabulary" \
  -- bash "$CHECK_SETTINGS"

settings_file <<'JSON'
{
  "stage": 3,
  "stage_1": {
    "spec_required": "always",
    "decisions_style": "adr",
    "product_layout": "by-concept"
  },
  "stage_2": {
    "auto_commit": true,
    "auto_pr": true,
    "auto_push": true,
    "agent_coauthor": true,
    "pr_title_style": "conventional"
  }
}
JSON
check "decisions_style takes per-subsystem or chronological" 1 \
  "decisions_style 'adr' is outside its vocabulary" \
  -- bash "$CHECK_SETTINGS"

settings_file <<'JSON'
{
  "stage": 3,
  "stage_1": {
    "spec_required": "always",
    "decisions_style": "chronological",
    "product_layout": "by-audience"
  },
  "stage_2": {
    "auto_commit": true,
    "auto_pr": true,
    "auto_push": true,
    "agent_coauthor": true,
    "pr_title_style": "conventional"
  }
}
JSON
check "product_layout takes by-concept or by-feature" 1 \
  "product_layout 'by-audience' is outside its vocabulary" \
  -- bash "$CHECK_SETTINGS"

finish

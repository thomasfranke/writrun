#!/usr/bin/env bash
. "$(dirname "$0")/../../../pipeline_lib.sh"

# The ledger is a declared variant, not part of the mandatory core: a
# project states whether it keeps one, and a project that keeps none
# records nothing and satisfies every check
# (docs/product/concepts/provenance.md#the-adopter-decides-whether-to-keep-it).
#
# Its documented default is `false`, and that is the same rule every other
# default follows — the behaviour from before the key existed. No ledger
# existed, so recording nothing is what the default preserves.
setup

check "with no file at all, no ledger is kept" 0 "false" \
  -- bash "$READ_SETTING" stage_1.provenance_ledger

settings_file <<'JSON'
{
  "stage": 3,
  "stage_1": {
    "decisions_style": "per-subsystem",
    "product_layout": "by-concept",
    "spec_required": "when-warranted"
  },
  "stage_2": {
    "agent_coauthor": true,
    "auto_commit": true,
    "auto_pr": true,
    "auto_push": true,
    "pr_title_style": "conventional"
  }
}
JSON
check "a file omitting the key falls back the same way" 0 "false" \
  -- bash "$READ_SETTING" stage_1.provenance_ledger
check "but the check will not let it stay omitted" 1 \
  "'stage_1.provenance_ledger' is missing" \
  -- bash "$CHECK_SETTINGS"

settings_file <<'JSON'
{
  "stage": 3,
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
    "pr_title_style": "conventional"
  }
}
JSON
check "a project that keeps one says so" 0 "true" \
  -- bash "$READ_SETTING" stage_1.provenance_ledger
check "and the file is canonical" 0 "is canonical" \
  -- bash "$CHECK_SETTINGS"

# The address is the key's identity, and this one's home is stage_1: the
# field it governs exists with no forge and no pull request anywhere.
settings_file <<'JSON'
{
  "stage": 3,
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
    "pr_title_style": "conventional",
    "provenance_ledger": false
  }
}
JSON
check "declared in the wrong section, it is homeless" 1 \
  "its home is stage_1" \
  -- bash "$CHECK_SETTINGS"

settings_file <<'JSON'
{
  "stage": 3,
  "stage_1": {
    "decisions_style": "per-subsystem",
    "product_layout": "by-concept",
    "provenance_ledger": "yes",
    "spec_required": "when-warranted"
  },
  "stage_2": {
    "agent_coauthor": true,
    "auto_commit": true,
    "auto_pr": true,
    "auto_push": true,
    "pr_title_style": "conventional"
  }
}
JSON
check "and it holds only its two values" 1 \
  "provenance_ledger 'yes' is outside its vocabulary" \
  -- bash "$CHECK_SETTINGS"

finish

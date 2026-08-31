#!/usr/bin/env bash
. "$(dirname "$0")/../../../pipeline_lib.sh"

# `credit_ai` became `agent_coauthor` (decision 0057), and the rename has
# a bridge for the same reason `level`'s does: an adopter who wrote
# `false` to switch the obligation off must not wake to it switched on
# because a key changed names under them. Read as "absent, so the
# default", the opt-out would invert into an obligation and
# check_observance.sh would flip from forbidding credit to demanding
# trailers — the loudest possible way for a rename to break a choice.
setup
settings_file <<'JSON'
{
  "stage": 3,
  "stage_2": {
    "credit_ai": false,
    "pr_title_style": "conventional"
  }
}
JSON
check "the old opt-out is still an opt-out" 0 "false" \
  -- bash "$READ_SETTING" stage_2.agent_coauthor
check "while the check names the rename" 1 "'credit_ai' was renamed" \
  -- bash "$CHECK_SETTINGS"
check "and names the key that replaced it" 1 "agent_coauthor" \
  -- bash "$CHECK_SETTINGS"

# The bridge carries the value, it does not impose one: `true` under the
# old name reads as `true`, which is also the default — so the case that
# proves the bridge is the one above, and this one proves it does not
# invert in the other direction either.
settings_file <<'JSON'
{
  "stage": 3,
  "stage_2": {
    "credit_ai": true,
    "pr_title_style": "conventional"
  }
}
JSON
check "and the old opt-in is still an opt-in" 0 "true" \
  -- bash "$READ_SETTING" stage_2.agent_coauthor

# The new name wins wherever it is written: the bridge is consulted only
# when the addressed key is absent, so a file carrying both is never read
# as the older of the two.
settings_file <<'JSON'
{
  "stage": 3,
  "stage_2": {
    "agent_coauthor": false,
    "credit_ai": true,
    "pr_title_style": "conventional"
  }
}
JSON
check "the new name wins over the old one" 0 "false" \
  -- bash "$READ_SETTING" stage_2.agent_coauthor

finish

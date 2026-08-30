#!/usr/bin/env bash
. "$(dirname "$0")/../../../pipeline_lib.sh"

# The file carries only what Adoption leaves open. A key switching off
# something from the core list is refused, not discouraged — a project
# that drops one of those is no longer following the methodology, and a
# setting that let it would say otherwise.
setup

settings_file <<'JSON'
{
  "stage": 3,
  "pr_title_style": "conventional",
  "audience_split": false
}
JSON
check "a key switching off the audience split is refused" 1 \
  "names a rule Adoption lists as core" \
  -- bash "$CHECK_SETTINGS"

settings_file <<'JSON'
{
  "stage": 3,
  "pr_title_style": "conventional",
  "human_gates": false
}
JSON
check "and one switching off the gates is refused" 1 \
  "names a rule Adoption lists as core" \
  -- bash "$CHECK_SETTINGS"

finish

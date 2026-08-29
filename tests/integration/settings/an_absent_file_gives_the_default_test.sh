#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

# Absence is not an error. An adopter who deletes the file keeps working,
# with the behaviour the schema documents — the same posture the lister
# takes when no forge answers.
setup
check "no file gives the documented level" 0 "github-issues" \
  -- bash "$READ_SETTING" level
check "and the documented style" 0 "conventional" \
  -- bash "$READ_SETTING" pr_title_style

# A key missing from a file that exists is the same absence.
settings_file <<'JSON'
{
  "pr_title_style": "bracketed"
}
JSON
check "a key the file omits falls back the same way" 0 "github-issues" \
  -- bash "$READ_SETTING" level

# And the check does not turn the file into a requirement.
setup
check "an absent file is not a fault" 0 "documented defaults apply" \
  -- bash "$CHECK_SETTINGS"

finish

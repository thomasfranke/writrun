#!/usr/bin/env bash
. "$(dirname "$0")/../../../pipeline_lib.sh"

# Absence is not an error. An adopter who deletes the file keeps working,
# with the behaviour the schema documents — the same posture the lister
# takes when no forge answers. Each documented default is the behaviour
# from before its key existed.
setup
check "no file gives the documented stage" 0 "3" \
  -- bash "$READ_SETTING" stage
check "and the documented style" 0 "conventional" \
  -- bash "$READ_SETTING" stage_2.pr_title_style
check "and the agent commits unprompted" 0 "true" \
  -- bash "$READ_SETTING" stage_2.auto_commit
check "and opens pull requests unprompted" 0 "true" \
  -- bash "$READ_SETTING" stage_2.auto_pr
check "and pushes unprompted" 0 "true" \
  -- bash "$READ_SETTING" stage_2.auto_push
check "and credits itself as its platform does" 0 "true" \
  -- bash "$READ_SETTING" stage_2.credit_ai
check "a spec is written when the work warrants one" 0 "when-warranted" \
  -- bash "$READ_SETTING" stage_1.spec_required
check "decisions sit per subsystem" 0 "per-subsystem" \
  -- bash "$READ_SETTING" stage_1.decisions_style
check "and the product half is organized by concept" 0 "by-concept" \
  -- bash "$READ_SETTING" stage_1.product_layout

# A key missing from a file that exists is the same absence.
settings_file <<'JSON'
{
  "stage_2": {
    "pr_title_style": "bracketed"
  }
}
JSON
check "a key the file omits falls back the same way" 0 "3" \
  -- bash "$READ_SETTING" stage
check "and so does a section the file omits entirely" 0 "when-warranted" \
  -- bash "$READ_SETTING" stage_1.spec_required

# An address the schema does not document has no documented default, so
# it prints nothing — and that is still not an error.
check "an undocumented address prints nothing, and exits 0" 0 "" \
  -- bash "$READ_SETTING" stage_2.invented

# And the check does not turn the file into a requirement.
setup
check "an absent file is not a fault" 0 "documented defaults apply" \
  -- bash "$CHECK_SETTINGS"

finish

#!/usr/bin/env bash
. "$(dirname "$0")/../../../pipeline_lib.sh"

# The file has one address, `.writrun/settings.json`, and a file left at
# the old one keeps working: the reader honours it flat, under the
# contract frozen at the move, and only the check tells the adopter to
# move it. That is the `level` precedent, applied to an address
# (docs/technical/decisions/tasks-and-specs/0053-settings-at-the-root.md).
setup

legacy_settings_file <<'JSON'
{
  "stage": 2,
  "pr_title_style": "bracketed"
}
JSON
check "an unmoved file is honoured exactly as before the move" 0 "2" \
  -- bash "$READ_SETTING" stage
check "and it still stops the machinery it stopped" 0 "stops below 3" \
  -- bash "$STAGE_GATE" 3
check "the off-switch message names the file that actually said so" 0 \
  "because .writrun/conventions/settings.json says so" \
  -- bash "$STAGE_GATE" 3
check "a sectioned address finds its key flat there" 0 "bracketed" \
  -- bash "$READ_SETTING" stage_2.pr_title_style
check "a key the frozen contract never had falls back to its default" 0 \
  "true" \
  -- bash "$READ_SETTING" stage_1.auto_commit
check "while the check names the move" 1 \
  "it moved to .writrun/settings.json" \
  -- bash "$CHECK_SETTINGS"

# Both addresses at once: one file, one address, never a silent tie.
settings_file <<'JSON'
{
  "stage": 3,
  "stage_1": {
    "auto_commit": true,
    "credit_ai": true
  },
  "stage_2": {
    "auto_pr": true,
    "pr_title_style": "conventional"
  }
}
JSON
check "with both present the new address wins outright" 0 "3" \
  -- bash "$READ_SETTING" stage
check "and the legacy address is ignored entirely" 0 "conventional" \
  -- bash "$READ_SETTING" stage_2.pr_title_style
check "while the check faults the leftover" 1 "is left over" \
  -- bash "$CHECK_SETTINGS"

# With the leftover gone, the same file is canonical.
setup
settings_file <<'JSON'
{
  "stage": 3,
  "stage_1": {
    "auto_commit": true,
    "credit_ai": true
  },
  "stage_2": {
    "auto_pr": true,
    "pr_title_style": "conventional"
  }
}
JSON
check "a file at the one address, alone, is canonical" 0 "is canonical" \
  -- bash "$CHECK_SETTINGS"

finish

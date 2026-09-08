#!/usr/bin/env bash
. "$(dirname "$0")/../../../pipeline_lib.sh"

# The file has one address, `writrun/settings.json`, and a file left at
# either old one keeps working: the reader honours the kit-home file
# as-is (same shape, old house) and the pre-0053 file flat, under the
# contract frozen at that move — and only the check tells the adopter to
# move on. That is the `level` precedent, applied to an address, twice
# (docs/technical/decisions/tasks-and-specs/0074-the-adopters-files-leave-the-kit.md,
# docs/technical/decisions/tasks-and-specs/0053-settings-at-the-root.md).
setup

# The kit-home bridge: a file still where the kit lived before the split.
kit_home_settings_file <<'JSON'
{
  "stage": 2,
  "stage_2": {
    "pr_title_style": "bracketed"
  }
}
JSON
check "a file still in the kit's home is honoured exactly as before" 0 "2" \
  -- bash "$READ_SETTING" stage
check "and it still stops the machinery it stopped" 0 "stops below 3" \
  -- bash "$STAGE_GATE" 3
check "the off-switch message names the file that actually said so" 0 \
  "because .writrun/settings.json says so" \
  -- bash "$STAGE_GATE" 3
check "a sectioned address reads sectioned there — the shape never moved" 0 \
  "bracketed" \
  -- bash "$READ_SETTING" stage_2.pr_title_style
check "while the check names the move" 1 \
  "it moved to writrun/settings.json" \
  -- bash "$CHECK_SETTINGS"

# The pre-0053 bridge, still standing behind the newer one.
setup
legacy_settings_file <<'JSON'
{
  "stage": 2,
  "pr_title_style": "bracketed"
}
JSON
check "an unmoved pre-0053 file is honoured exactly as before that move" 0 "2" \
  -- bash "$READ_SETTING" stage
check "a sectioned address finds its key flat there" 0 "bracketed" \
  -- bash "$READ_SETTING" stage_2.pr_title_style
check "a key the frozen contract never had falls back to its default" 0 \
  "true" \
  -- bash "$READ_SETTING" stage_2.auto_commit
check "while the check names that move too" 1 \
  "it moved to writrun/settings.json" \
  -- bash "$CHECK_SETTINGS"

# Both addresses at once: one file, one address, never a silent tie.
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
    "auto_push": true,
    "agent_coauthor": true,
    "commit_scopes": "about product technical tasks specs skills ci tests agents readme setup queue conventions",
    "commit_types": "docs feat fix refactor chore",
    "pr_title_style": "conventional"
  }
}
JSON
check "with both present the new address wins outright" 0 "3" \
  -- bash "$READ_SETTING" stage
check "and the old address is ignored entirely" 0 "conventional" \
  -- bash "$READ_SETTING" stage_2.pr_title_style
check "while the check faults the leftover" 1 "is left over" \
  -- bash "$CHECK_SETTINGS"

# With the leftover gone, the same file is canonical.
setup
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
    "auto_push": true,
    "agent_coauthor": true,
    "commit_scopes": "about product technical tasks specs skills ci tests agents readme setup queue conventions",
    "commit_types": "docs feat fix refactor chore",
    "pr_title_style": "conventional"
  }
}
JSON
check "a file at the one address, alone, is canonical" 0 "is canonical" \
  -- bash "$CHECK_SETTINGS"

finish

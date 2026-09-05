#!/usr/bin/env bash
# How the tag meets the summary is the declared style's to spell, not one
# format string's. `bracketed` runs the brackets together and
# `conventional` keeps one space, exactly as the settings card prints
# them — a composer carrying the space always titled every bracketed
# pull request against the card a session is told to run for a value.
. "$(dirname "$0")/../../pipeline_lib.sh"

take_setup
task_file task-001 ready ""
commit_all
publish_main
check "a conventional project takes" 0 "Took task-001" \
  -- bash "$TAKE_TASK" task-001 --title "feat(ci): take it" --slug mirror-lag
check "and the space between the tag and the summary is kept" 0 "" \
  -- grep -q 'pr create .*--title \[TASK-0001\] feat(ci): take it' "$FORGE_LOG"

take_setup
settings_file <<'JSON'
{
  "stage": 2,
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
    "pr_title_style": "bracketed"
  }
}
JSON
task_file task-001 ready ""
commit_all
publish_main
check "a bracketed project takes" 0 "Took task-001" \
  -- bash "$TAKE_TASK" task-001 --title "[Feat][Ci] Take it" --slug mirror-lag
check "and the tag meets the first bracket with nothing between them" 0 "" \
  -- grep -q 'pr create .*--title \[TASK-0001\]\[Feat\]\[Ci\] Take it' "$FORGE_LOG"

# A style nobody declared is check_settings.sh's to name. Composing the
# tighter spelling on a guess would be this script deciding which style
# the project meant, so the space stays — the same direction the summary
# check takes when it judges nothing.
take_setup
settings_file <<'JSON'
{
  "stage": 2,
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
    "pr_title_style": "haiku"
  }
}
JSON
task_file task-001 ready ""
commit_all
publish_main
check "an unreadable style still takes" 0 "Took task-001" \
  -- bash "$TAKE_TASK" task-001 --title "Take it" --slug mirror-lag
check "and keeps the space rather than guessing a style" 0 "" \
  -- grep -q 'pr create .*--title \[TASK-0001\] Take it' "$FORGE_LOG"

finish

#!/usr/bin/env bash
. "$(dirname "$0")/../../../pipeline_lib.sh"

# The top level is where this repository already was, so shipping the
# mechanism at today's values changes nothing that runs.
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
    "auto_pr": true,
    "auto_push": true,
    "agent_coauthor": true,
    "pr_title_style": "conventional"
  }
}
JSON
check "writrun check and approve run" 0 "reaches 2" \
  -- bash "$STAGE_GATE" 2
check "and so do issues and progress" 0 "reaches 3" \
  -- bash "$STAGE_GATE" 3

# A level outside the vocabulary is check_settings.sh's fault to name;
# the gate keeps the machinery running rather than stopping it silently.
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
check "an unreadable level does not silently stop the machinery" 0 \
  "reaches 3" \
  -- bash "$STAGE_GATE" 3

finish

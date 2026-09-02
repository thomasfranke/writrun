#!/usr/bin/env bash
# It replaces reading, so growing is regressing: the bound is what keeps
# the next key from being added as a paragraph.
. "$(dirname "$0")/../../pipeline_lib.sh"

setup
n=$(bash "$SESSION_CARD" | wc -l | tr -d ' ')
if [ "$n" -le 34 ]; then
  echo "ok    the card fits in ~30 lines ($n)"; pass=$((pass + 1))
else
  echo "FAIL  the card fits in ~30 lines ($n)"; fail=$((fail + 1))
fi

# Stage 1 has no pull requests, and the flags still print — they bind
# from Stage 2 up, and the card says so rather than hiding them.
settings_file <<'JSON'
{
  "stage": 1,
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
check "at Stage 1 the flags still print" 0 "auto_commit:" -- bash "$SESSION_CARD"
check "and the card says when they bind" 0 "bind from Stage 2 up" -- bash "$SESSION_CARD"

finish

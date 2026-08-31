#!/usr/bin/env bash
. "$(dirname "$0")/../../../pipeline_lib.sh"

# The machinery writes commits that nothing squashes, so a subject in the
# undeclared style sits on the default branch for good. Two workflows
# write them; the subject is composed in one place, from the same key
# every agent-written title obeys.
SUBJECT="$CI_SCRIPTS/stage-2-pull-requests/commit_subject.sh"

setup
settings_file <<'JSON'
{
  "stage": 3,
  "stage_1": {
    "decisions_style": "per-subsystem",
    "product_layout": "by-concept",
    "spec_required": "when-warranted"
  },
  "stage_2": {
    "auto_commit": true,
    "auto_pr": true,
    "auto_push": true,
    "credit_ai": true,
    "pr_title_style": "bracketed"
  }
}
JSON
check "the merge recording takes the declared style" 0 \
  "\[Chore\]\[Queue\] Record what the merge decided" \
  -- bash "$SUBJECT" merge
check "and so does the forge recording" 0 \
  "\[Chore\]\[Queue\] Record what the forge just did" \
  -- bash "$SUBJECT" forge

settings_file <<'JSON'
{
  "stage": 3,
  "stage_1": {
    "decisions_style": "per-subsystem",
    "product_layout": "by-concept",
    "spec_required": "when-warranted"
  },
  "stage_2": {
    "auto_commit": true,
    "auto_pr": true,
    "auto_push": true,
    "credit_ai": true,
    "pr_title_style": "conventional"
  }
}
JSON
check "the other style is written the other way" 0 \
  "chore(queue): record what the merge decided" \
  -- bash "$SUBJECT" merge
check "for both events" 0 "chore(queue): record what the forge just did" \
  -- bash "$SUBJECT" forge

# Absence is not an error anywhere else the settings are read, and this
# is no exception: the documented default is what the workflows wrote
# before the key was consulted at all.
rm -f .writrun/settings.json
check "no settings file gives the documented default" 0 \
  "chore(queue): record what the merge decided" \
  -- bash "$SUBJECT" merge

check "an event the machinery does not have is a usage error" 3 \
  "usage: commit_subject.sh" \
  -- bash "$SUBJECT" release
check "and so is no event at all" 3 "usage: commit_subject.sh" \
  -- bash "$SUBJECT"

finish

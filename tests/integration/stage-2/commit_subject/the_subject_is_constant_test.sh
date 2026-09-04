#!/usr/bin/env bash
. "$(dirname "$0")/../../../pipeline_lib.sh"

# The machinery writes commits that nothing squashes, and what they land
# on is `main` — read by bisect, by release tooling and by whoever
# arrives in a year, an audience that is the same in every project. So
# the subject is Conventional Commits everywhere and `pr_title_style`,
# which governs the pull request title, is not consulted at all
# (docs/technical/decisions/pull-requests/0063-title-and-subject-are-two-texts.md).
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
    "agent_coauthor": true,
    "pr_title_style": "bracketed"
  }
}
JSON
check "the merge recording is conventional under the bracketed style" 0 \
  "chore(queue): record what the merge decided" \
  -- bash "$SUBJECT" merge
check "and so is the forge recording" 0 \
  "chore(queue): record what the forge just did" \
  -- bash "$SUBJECT" forge
check "and so is the intake's" 0 \
  "chore(queue): record what the label let in" \
  -- bash "$SUBJECT" intake
refute "the style the titles take does not dress the subject" \
  "\[Chore\]\[Queue\]" \
  -- bash "$SUBJECT" merge

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
    "agent_coauthor": true,
    "pr_title_style": "conventional"
  }
}
JSON
check "the other declaration writes the same subject" 0 \
  "chore(queue): record what the merge decided" \
  -- bash "$SUBJECT" merge
check "for both events" 0 "chore(queue): record what the forge just did" \
  -- bash "$SUBJECT" forge

# The key is not read, so neither is the file it lives in. A settings
# file the reader could not parse is the evidence: under the old script
# this line ran `read_setting.sh`, and here nothing looks.
printf 'not json at all\n' > .writrun/settings.json
check "an unreadable settings file is not even opened" 0 \
  "chore(queue): record what the merge decided" \
  -- bash "$SUBJECT" merge

rm -f .writrun/settings.json
check "and neither is a settings file that is absent" 0 \
  "chore(queue): record what the forge just did" \
  -- bash "$SUBJECT" forge

check "an event the machinery does not have is a usage error" 3 \
  "usage: commit_subject.sh" \
  -- bash "$SUBJECT" release
check "and so is no event at all" 3 "usage: commit_subject.sh" \
  -- bash "$SUBJECT"

finish

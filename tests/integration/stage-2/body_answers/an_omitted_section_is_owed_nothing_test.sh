#!/usr/bin/env bash
. "$(dirname "$0")/../../../pipeline_lib.sh"

# What the rule reads is the headings a body has, never a list of the
# headings it could have. The template ships three kind-specific sections
# and says to keep the one that applies; a fixed list here would be a
# second copy of the template, wrong the first time an adopter edits
# theirs.
setup
stub_forge
forge_pr_body 7 <<'MD'
## What

A one-line fix.

## Why

It was wrong.
MD

check "a body carrying two sections owes two answers" 0 "2 sections" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/check_body_answers.sh" o/r 7

refute "and nothing is said about the sections it left out" "How to test" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/check_body_answers.sh" o/r 7

# Deleting a section is therefore a way through, and the right one: the
# alternative — a heading kept and left blank — is exactly what this
# check refuses.
finish

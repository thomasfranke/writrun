#!/usr/bin/env bash
# The vocabularies come from check_observance.sh's own assignment lines —
# the machine half of conventions/commits.md, and what the door actually
# enforces. A card that could not find them must not look complete.
. "$(dirname "$0")/../../pipeline_lib.sh"

setup
check "the types are the script's list" 0 "docs feat fix refactor chore" -- bash "$SESSION_CARD"
check "and so are the scopes" 0 "about product technical tasks specs skills" -- bash "$SESSION_CARD"

# A copy of the tree whose vocabulary lines are gone: the card refuses
# rather than printing a shorter one.
setup
mkdir -p fake/stage-1-tasks-and-specs fake/stage-2-pull-requests
cp "$SESSION_CARD" fake/stage-1-tasks-and-specs/session_card.sh
cp "$READ_SETTING" fake/stage-2-pull-requests/read_setting.sh
sed 's/^TYPES=.*/# the line is gone/; s/^SCOPES=.*/# and so is this one/' \
  "$CHECK_OBSERVANCE" > fake/stage-2-pull-requests/check_observance.sh
check "a missing vocabulary is a loud exit 3" 3 "Could not read the TYPES/SCOPES lines" \
  -- bash fake/stage-1-tasks-and-specs/session_card.sh

finish

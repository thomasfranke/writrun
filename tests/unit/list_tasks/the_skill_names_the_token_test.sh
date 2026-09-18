#!/usr/bin/env bash
# The skill enumerates what a row says, and a skill that does not name a
# field is a field the session never reads. There is no runtime signal
# for a stale skill, which is why this is a case rather than a habit.
. "$(dirname "$0")/../../harness.sh"

SKILL="$REPO_ROOT/.writrun/skills/writrun-select-next-task/SKILL.md"

check "the skill names the spec token" 0 "spec-NNNN:status" \
  -- grep -o "spec-NNNN:status" "$SKILL"
check "and says what an empty spec_ref prints" 0 "no-spec" \
  -- grep -o "no-spec" "$SKILL"

finish

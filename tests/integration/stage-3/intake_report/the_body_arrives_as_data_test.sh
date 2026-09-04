#!/usr/bin/env bash
. "$(dirname "$0")/../../../intake_lib.sh"

# The issue's text was written by whoever opened it. It reaches the
# report through the environment and printf, never interpolated into
# shell or YAML — so substitution syntax arrives as the characters it
# is, and a front-matter block of the body's own never becomes the
# file's (docs/technical/reporting/intake.md).
setup_intake

export ISSUE_TITLE="A body that tries everything"
ISSUE_BODY='---
status: tracked
---
`rm -rf /` and $(touch pwned) and ${HOME} and
a plain second line'
export ISSUE_BODY

check "the intake records it" 0 "recorded work/reports/report-0001" \
  -- bash "$INTAKE" o/r 9

check "nothing in the body executed" 1 "" \
  -- test -e pwned

FILE=$(authority ls-tree --name-only main:work/reports | grep '^report-0001')
check "the substitution syntax arrives verbatim" 0 \
  'and $(touch pwned) and ${HOME} and' \
  -- authority show "main:work/reports/${FILE}"
check "so does the body's own front-matter block" 0 \
  "status: tracked" \
  -- authority show "main:work/reports/${FILE}"

# And the file the body could not corrupt is canonical: the front
# matter is the intake's, read from line 1, and the body's imitation of
# one is body text like any other.
git pull -q --rebase origin main 2>/dev/null
check "the recorded report passes the front-matter check" 0 \
  "all canonical" \
  -- bash "$REPO_ROOT/.writrun/skills/writrun-check-front-matter/check_front_matter.sh"

finish

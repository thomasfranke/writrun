#!/usr/bin/env bash
. "$(dirname "$0")/../../../intake_lib.sh"

# The intake is the caller that needs the fourth input most — it mints
# straight onto the authority branch with no pull-request gate behind it
# — and it is the only caller that pins the repository. Both halves of
# that matter: the mirror has to raise the number, and it has to be *this
# repository's* mirror, or the scan reads one project's numbers and
# another's answers.
setup_intake
forge_mirror report '[REPORT-0006] A finding whose branch never merged'

export ISSUE_TITLE="The generator reuses ids"
check "the mint clears the id a mirror still holds" 0 \
  "recorded work/reports/report-0007-the-generator-reuses.md" \
  -- bash "$INTAKE" o/r 9

forge_told "and the mirrors it asked for were the pinned repository's" \
  "repos/o/r/issues?labels=writrun:report&state=all"

finish

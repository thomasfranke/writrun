#!/usr/bin/env bash
. "$(dirname "$0")/../../../intake_lib.sh"

# The durable no-op guard is the file, never the title. The retitle is
# the last write, so a run that died between the push and the retitle
# leaves the report recorded and the issue untagged — and the next
# label application must not mint a second id for the same observation.
# The script finds the report already naming the issue (the `Issue #N`
# line it wrote) and re-dresses the mirror only.
setup_intake

export ISSUE_TITLE="Observed exactly once"
check "the first delivery records the report" 0 \
  "recorded work/reports/report-0001-observed-exactly-once.md" \
  -- bash "$INTAKE" o/r 9

# The retitle never landed (the title arrives untagged again), so the
# tag guard cannot answer — the file must.
git pull -q --rebase origin main 2>/dev/null
: > "$FAKE_GH_LOG"
check "the second delivery mints nothing" 0 \
  "already recorded as work/reports/report-0001-observed-exactly-once.md" \
  -- bash "$INTAKE" o/r 9
refute "no second file appeared on the authority branch" "report-0002" \
  -- authority ls-tree --name-only main:work/reports
forge_told "and the mirror dressing is redone for the first id" \
  "title=[REPORT-0001] Observed exactly once"

# A different issue is a different observation: the guard is keyed on
# the issue number, never on the title.
: > "$FAKE_GH_LOG"
check "another issue with the same title still mints" 0 \
  "recorded work/reports/report-0002-observed-exactly-once.md" \
  -- bash "$INTAKE" o/r 10

finish

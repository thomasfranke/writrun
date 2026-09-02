#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

# The mechanical half of triage. The link runs one way — the report names
# the tasks triage produced, and the task schema is untouched — so the
# generator is the only place that knows both ids at once, and this edit
# belongs there rather than in an agent's memory.
setup
# The tracked route travels on its own reporting change, and both
# the generator and check_state read the branch name to hold it there.
git branch -m report/something-seen
bash "$NEW_SH" report "The mirror lags" --slug mirror-lag >/dev/null 2>&1
bash "$NEW_SH" task "Read the merged ref" --slug merged-ref \
  --from-report report-0001 >/dev/null 2>&1
r=work/reports/report-0001-mirror-lag.md
if grep -q '^task_ref: \[task-0001\]$' "$r" &&
   grep -q '^status: tracked$' "$r" &&
   ! grep -q '^triaged: null$' "$r"; then
  echo "ok    triage's three writes land together"; pass=$((pass + 1))
else
  echo "FAIL  triage's three writes land together"
  sed 's/^/      | /' "$r"; fail=$((fail + 1))
fi

# `--from-report` states the origin rather than defaulting it: the flag
# names the report the task was born from, which is the whole content of
# `origin: report`.
if grep -q '^origin: report$' work/tasks/task-0001-merged-ref.md; then
  echo "ok    the origin is stated by the flag, not asked for again"; pass=$((pass + 1))
else
  echo "FAIL  the origin is stated by the flag, not asked for again"; fail=$((fail + 1))
fi

# Triage can split one finding, which is why task_ref is a list — and why
# the second run must find the first one's id still there. The date stays
# the first judgement's: a second task does not re-date it.
first_date=$(sed -n 's/^triaged: //p' "$r")
bash "$NEW_SH" task "And the labels" --slug the-labels \
  --from-report report-0001 >/dev/null 2>&1
if grep -q '^task_ref: \[task-0001, task-0002\]$' "$r" &&
   grep -q "^triaged: ${first_date}\$" "$r"; then
  echo "ok    a second task appends, and re-dates nothing"; pass=$((pass + 1))
else
  echo "FAIL  a second task appends, and re-dates nothing"
  sed 's/^/      | /' "$r"; fail=$((fail + 1))
fi

check "the report is still canonical after both appends" 0 "all canonical" \
  -- bash "$CHECK_FRONT_MATTER" work/tasks work/specs docs work/reports

# The refusals: a report that does not resolve, and an origin that
# contradicts the flag. A task cannot be derived from a rule and born
# from a report.
check "a report that does not resolve refuses" 3 "No such report" \
  -- bash "$NEW_SH" task "Nowhere" --from-report report-0099
check "--origin rule beside it refuses" 3 "contradicts it" \
  -- bash "$NEW_SH" task "Both" --from-report report-0001 --origin rule

# Triage ran once. A report it already ended is never re-routed — a
# recurrence is a second observation, with its own id and its own date.
report_file report-0004 declined "" 2026-08-22T01:00:00Z
check "a terminal report is not re-routed" 3 "never re-routed" \
  -- bash "$NEW_SH" task "Too late" --from-report report-0004

finish

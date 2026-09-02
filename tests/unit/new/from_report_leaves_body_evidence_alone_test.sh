#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

# A report's body quotes front matter, because that is what evidence looks
# like: the observation *is* "the file says `status: open` and the mirror
# says otherwise". Every rewrite triage makes therefore has to know the
# difference between a field and a quotation of one — an unanchored
# `/^status: /` edits both, and the file it leaves is still canonical, so
# no check downstream ever notices that the evidence now says something
# nobody observed.
setup
# The tracked route travels on its own reporting change, and both
# the generator and check_state read the branch name to hold it there.
git branch -m report/something-seen
bash "$NEW_SH" report "The mirror lags" --slug mirror-lag >/dev/null 2>&1
r=work/reports/report-0001-mirror-lag.md
cat >> "$r" <<'EVIDENCE'

The file on `main` reads:

```
status: open
triaged: null
task_ref: []
```

...while the mirror is closed.
EVIDENCE

bash "$NEW_SH" task "Read the merged ref" --slug merged-ref \
  --from-report report-0001 >/dev/null 2>&1

# The front matter moved — all three fields, as triage's mechanical half
# is meant to.
block=$(awk 'NR == 1 { next } /^---$/ { exit } { print }' "$r")
if printf '%s\n' "$block" | grep -q '^status: tracked$' &&
   printf '%s\n' "$block" | grep -q '^task_ref: \[task-0001\]$' &&
   ! printf '%s\n' "$block" | grep -q '^triaged: null$'; then
  echo "ok    triage still writes the front matter"; pass=$((pass + 1))
else
  echo "FAIL  triage still writes the front matter"
  sed 's/^/      | /' "$r"; fail=$((fail + 1))
fi

# ...and the quoted block did not. Counted, not grepped: `status: open`
# now appears exactly once in the file, in the fence, and `status:
# tracked` exactly once, in the block.
quoted=$(awk '/^```$/ { inf = !inf; next } inf' "$r")
if [ "$(printf '%s\n' "$quoted" | grep -c '^status: open$')" = "1" ] &&
   [ "$(printf '%s\n' "$quoted" | grep -c '^triaged: null$')" = "1" ] &&
   [ "$(printf '%s\n' "$quoted" | grep -c '^task_ref: \[\]$')" = "1" ]; then
  echo "ok    the evidence it was written about is untouched"; pass=$((pass + 1))
else
  echo "FAIL  the evidence it was written about is untouched"
  sed 's/^/      | /' "$r"; fail=$((fail + 1))
fi

check "and the report is canonical either way" 0 "all canonical" \
  -- bash "$CHECK_FRONT_MATTER" work/tasks work/specs docs work/reports

# The same anchoring on the other side of the link: a *task* body quoting
# `spec_ref: []` is not the task's spec_ref, and `new.sh spec` appends to
# the field alone.
setup
bash "$NEW_SH" task "Carry the work" --slug carry-work --origin rule >/dev/null 2>&1
t=work/tasks/task-0001-carry-work.md
[ -f "$t" ] || { echo "FAIL  the fixture's task was not created"; fail=$((fail + 1)); }
cat >> "$t" <<'EVIDENCE'

A task with no spec reads:

```
spec_ref: []
```
EVIDENCE
bash "$NEW_SH" spec task-0001 "How to carry it" --slug carry-it >/dev/null 2>&1
if grep -q '^spec_ref: \[spec-0001\]$' "$t" &&
   [ "$(grep -c '^spec_ref: \[\]$' "$t")" = "1" ]; then
  echo "ok    a task's quoted spec_ref is left alone too"; pass=$((pass + 1))
else
  echo "FAIL  a task's quoted spec_ref is left alone too"
  sed 's/^/      | /' "$t"; fail=$((fail + 1))
fi

finish

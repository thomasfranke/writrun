#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

# The canonical report: every schema field present, `open` with nothing
# triaged yet, and the two links a report is born with — none. The
# directory is created by the generator, because an adopter's first
# report is exactly the moment work/reports/ does not exist yet.
setup
bash "$NEW_SH" report "The mirror lags behind main" \
  --doc-ref product/chapter.md#scope >/dev/null 2>&1
f=work/reports/report-0001-the-mirror-lags.md
if [ -f "$f" ] &&
   grep -q '^id: report-0001$'                  "$f" &&
   grep -q '^status: open$'                     "$f" &&
   grep -q '^task_ref: \[\]$'                   "$f" &&
   grep -q '^doc_ref: product/chapter.md#scope$' "$f" &&
   grep -q '^triaged: null$'                    "$f"; then
  echo "ok    a generated report carries every field explicitly"; pass=$((pass + 1))
else
  echo "FAIL  a generated report carries every field explicitly"
  [ -f "$f" ] && sed 's/^/      | /' "$f" || ls -R work/reports 2>&1 | sed 's/^/      | /'
  fail=$((fail + 1))
fi

# And it is canonical to the checker that reads the real queue, not just
# to a grep written beside the generator.
check "the generated report passes the front-matter check" 0 "" \
  -- bash "$CHECK_FRONT_MATTER" work/tasks work/specs docs work/reports

finish

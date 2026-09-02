#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

# An adopter who has never recorded a report has no work/reports/, and
# that is a complete state rather than a broken checkout. Every gate has
# to read it as zero reports — the day one of them reads it as an error
# is the day the third kind stops being optional.
setup
task_file task-0001 backlog ""
commit_all

if [ -d work/reports ]; then
  echo "FAIL  the fixture starts without a reports directory"; fail=$((fail + 1))
else
  echo "ok    the fixture starts without a reports directory"; pass=$((pass + 1))
fi

check "the front-matter check reads it as zero reports" 0 "all canonical" \
  -- bash "$CHECK_FRONT_MATTER"
refute "and says nothing about a missing directory" "reports" \
  -- bash "$CHECK_FRONT_MATTER"

check "the state check reads it the same way" 0 "no forbidden lifecycle" \
  -- bash "$CHECK_STATE" main...HEAD

stub_forge
check "and so does the id check" 0 "No id collides" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/check_unique_ids.sh" main...HEAD o/r 7

# The generator is what ends the state, and it creates the directory
# rather than requiring one.
bash "$NEW_SH" report "The first one anybody wrote" --slug first-one >/dev/null 2>&1
if [ -f work/reports/report-0001-first-one.md ]; then
  echo "ok    the first report makes the directory"; pass=$((pass + 1))
else
  echo "FAIL  the first report makes the directory"; fail=$((fail + 1))
fi

finish

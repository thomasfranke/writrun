#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

# The fourth input is guarded by the prefix the mint was called with, and
# the guard has to hold in both directions: a task's mirror raises a task
# and says nothing about a spec. Only tasks and reports are mirrored, so
# a spec mint reads the three views it always read and no fourth.
setup
stub_forge
forge_mirror task '[TASK-0009] A task whose branch never merged'
forge_mirror report '[REPORT-0044] And a report of its own'

check "a task mirror raises a task mint" 0 "every mirror" \
  -- bash "$NEW_SH" task "Mine" --origin rule
if [ -f work/tasks/task-0010-mine.md ]; then
  echo "ok    above the highest id a task mirror names"; pass=$((pass + 1))
else
  echo "FAIL  above the highest id a task mirror names"
  ls work/tasks | sed 's/^/      | /'
  fail=$((fail + 1))
fi

check "a spec mint reads no mirror at all" 0 "every mirror" \
  -- bash "$NEW_SH" spec task-0010 "Its spec"
if [ -f work/specs/spec-0001-its-spec.md ]; then
  echo "ok    and starts where the three views left it"; pass=$((pass + 1))
else
  echo "FAIL  and starts where the three views left it"
  ls work/specs | sed 's/^/      | /'
  fail=$((fail + 1))
fi

# An Issue a maintainer labelled by hand carries no tag until the intake
# retitles it. It names no id, so it raises nothing and fails nothing.
forge_mirror report 'Something was observed'
check "an untagged mirror is not an error" 0 "every mirror" \
  -- bash "$NEW_SH" report "Observed too"
if [ -f work/reports/report-0045-observed-too.md ]; then
  echo "ok    and contributes no number"; pass=$((pass + 1))
else
  echo "FAIL  and contributes no number"
  ls work/reports | sed 's/^/      | /'
  fail=$((fail + 1))
fi

finish

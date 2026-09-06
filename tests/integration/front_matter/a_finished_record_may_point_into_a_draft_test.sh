#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

# The draft refusal is present tense — "nothing DERIVES from a chapter
# that is not a rule yet". A finished record derives nothing: its
# doc_ref records what it derived from, as the chapter stood then.
# Without this line, the sanctioned rule-to-draft demotion poisons the
# queue retroactively — every completed task and routed report into the
# chapter failing every later sweep, repairable only by editing history
# (report-0035, spec-0085).
setup
mkdir -p docs/product
printf '/// writrun:draft\n# Demoted, with a declaration\n' > docs/product/drafted.md

# A done task is history — the demotion scenario that today deadlocks.
task_file task-001 done "" 2026-08-23T00:00:00Z thomasfranke
sed -i.bak 's|^doc_ref: null$|doc_ref: product/drafted.md#anchor|' work/tasks/task-001.md && rm -f work/tasks/*.bak
check "a done task pointing into a draft passes" 0 "all canonical" \
  -- bash "$CHECK_FRONT_MATTER"

# A dropped task derives nothing by definition.
task_file task-001 dropped ""
sed -i.bak 's|^doc_ref: null$|doc_ref: product/drafted.md#anchor|' work/tasks/task-001.md && rm -f work/tasks/*.bak
check "a dropped task pointing into one passes" 0 "all canonical" \
  -- bash "$CHECK_FRONT_MATTER"

# A live task still refuses — the refusal #225 exists for is untouched.
# `backlog` here; `ready` is the sibling case's, and one live status
# stands for the set: the guard names the finished statuses and judges
# everything else live.
task_file task-001 backlog ""
sed -i.bak 's|^doc_ref: null$|doc_ref: product/drafted.md#anchor|' work/tasks/task-001.md && rm -f work/tasks/*.bak
check "a live task still refuses" 1 "names a draft chapter" \
  -- bash "$CHECK_FRONT_MATTER"

# A report whose route is an end is a record too; an open one still
# awaits triage, and still refuses.
rm work/tasks/task-001.md
report_file report-0001 fixed "" 2026-08-22T01:00:00Z "product/drafted.md"
check "a routed report pointing into one passes" 0 "all canonical" \
  -- bash "$CHECK_FRONT_MATTER"
report_file report-0001 open "" null "product/drafted.md"
check "an open report still refuses" 1 "names a draft chapter" \
  -- bash "$CHECK_FRONT_MATTER"

finish

#!/usr/bin/env bash
. "$(dirname "$0")/../../../mirror_lib.sh"

# The list is read once, and the job that reads it minted mirrors seconds
# earlier: the read can be older than the mirror it is asked about. So a
# miss on an id the mint answered for re-reads before it concludes
# anything (work/reports/report-0021-rederive-labels-sh.md).
setup_forge
base_task task-0008 ready ""
base_task task-0009 ready ""
forge_issue 10 open "writrun:task" "[TASK-0008] In the first read"
forge_relists
forge_issue 11 open "writrun:task" "[TASK-0009] Minted after it"
check "a minted id the first read missed is labelled from the second" 0 \
  "task-0009 → status:ready" \
  -- bash "$REDERIVE_LABELS" o/r task-0008 --minted task-0009
forge_told "and the mirror the re-read found is labelled like any other" \
  "PUT repos/o/r/issues/11/labels -f labels[]=writrun:task -f labels[]=status:ready -f labels[]=origin:rule"
forge_told_times "one re-read, not one read per id" 2 \
  "issues?labels=writrun:task"

# The budget belongs to the ids the mint answered for. A miss nobody
# minted, arriving first, is answered from the list in hand — the whole
# budget is still there for the minted miss behind it.
setup_forge
base_task task-0007 ready ""
base_task task-0009 ready ""
forge_relists
forge_issue 12 open "writrun:task" "[TASK-0009] Minted after the read"
check "a miss nobody minted leaves the whole budget to the minted one" 0 \
  "task-0007: no mirrored Issue." \
  -- bash "$REDERIVE_LABELS" o/r task-0007 --minted task-0009
forge_told "and the minted id still resolves, from the first re-read" \
  "PUT repos/o/r/issues/12/labels -f labels[]=writrun:task -f labels[]=status:ready"
forge_told_times "the unentitled miss having spent nothing" 2 \
  "issues?labels=writrun:task"

# The run the report caught: fourteen mirrors minted, the label pass
# invoked five milliseconds later, and the read it made saw only the
# first eight. The re-read is the run's rather than each id's, so one of
# them answers all six latecomers.
setup_forge
ids=()
i=1
while [ "$i" -le 14 ]; do
  ids+=("$(printf 'task-%04d' "$i")")
  base_task "$(printf 'task-%04d' "$i")" ready ""
  [ "$i" -eq 9 ] && forge_relists
  forge_issue $((i + 2)) open "writrun:task" \
    "[$(printf 'TASK-%04d' "$i")] Minted by this run"
  i=$((i + 1))
done
check "fourteen minted mirrors, eight in the first read, all labelled" 0 \
  "task-0014 → status:ready" \
  -- bash "$REDERIVE_LABELS" o/r "${ids[@]}" --minted "${ids[@]}"
forge_told "the last latecomer's mirror is labelled like the rest" \
  "PUT repos/o/r/issues/16/labels -f labels[]=writrun:task -f labels[]=status:ready"
forge_told_times "and the six of them cost one re-read between them" 2 \
  "issues?labels=writrun:task"

# The common path pays nothing: every id in the list the run started
# with, and no second read.
setup_forge
base_task task-0005 ready ""
forge_issue 31 open "writrun:task" "[TASK-0005] Already there"
check "a run whose ids all resolve first time" 0 "task-0005 → status:ready" \
  -- bash "$REDERIVE_LABELS" o/r task-0005
forge_told_times "reads the list once" 1 "issues?labels=writrun:task"

# A report mirror is the same projection one kind over, and its list is
# read the same way — so it goes stale the same way. Behind `--minted`,
# because that is the only shape a report id ever reaches this script in.
setup_forge
base_report report-0003 open
forge_relists report
forge_report_issue 31 open "writrun:report" "[REPORT-0003] Minted after the read"
check "a report mirror younger than the read is found too" 0 \
  "report-0003 → status:open" -- bash "$REDERIVE_LABELS" o/r --minted report-0003
forge_told_times "by a re-read of the report list alone" 2 \
  "issues?labels=writrun:report"

finish

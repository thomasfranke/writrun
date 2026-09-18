#!/usr/bin/env bash
# The completion edits, written and not committed. The bare shape is how
# the stages see them; a two-ended range is how they do not — and there
# the warning has to say so, because it used to read the checkout and
# fall silent over stages that read nothing (report-0046, decision 0080).
. "$(dirname "$0")/../../pipeline_lib.sh"

# The queue as the authority branch holds it mid-flight: the take wrote
# in-progress and the merge wrote approved, both already at the base. The
# range carries the implementation, and nothing else is born in it.
setup
task_file task-001 in-progress spec-001
spec_file spec-001 task-001 approved product/chapter.md
commit_all
git branch -q -f base HEAD

git checkout -qb task/0001-mirror-lag
printf 'the implementation\n' > engine.sh
commit_all                          # the work, committed; the queue untouched

# The completion edits: the promise kept, the spec implemented, the date
# written. Nothing committed — this is a finish flow mid-flight, and it
# is the state the whole rule is about.
printf '\nA rule the spec promised.\n' >> docs/product/chapter.md
sed -i.bak 's/^status: approved$/status: implemented/' work/specs/spec-001.md
sed -i.bak 's/^completed: null$/completed: 2026-09-17T12:00:00Z/' work/tasks/task-001.md
rm -f work/specs/spec-001.md.bak work/tasks/task-001.md.bak

# The bare shape: the stages read the tree, so the spec is named, its
# promise is judged, and the warning has nothing to warn about.
check "the bare shape judges the uncommitted edits" 0 "deltas checked: spec-001" \
  -- bash "$PREFLIGHT" base
refute "and warns about nothing, the date being there" "has no completed date" \
  -- bash "$PREFLIGHT" base

# The two-ended range: its head is a commit that has none of it, so the
# spec is not in the diff at all and the delta stage reads an authoring
# change. The run passes — nothing in it is wrong — and the whole of the
# fix is that it no longer passes *silently*.
check "a two-ended range names no spec" 0 "deltas checked: none" \
  -- bash "$PREFLIGHT" base...HEAD
check "and says the date is missing at the end it read" 0 \
  "has no completed date in" -- bash "$PREFLIGHT" base...HEAD
check "naming that end rather than the checkout" 0 "precedes the completion edits" \
  -- bash "$PREFLIGHT" base...HEAD

# A task file that exists only in the checkout has no head-side copy at
# all. That is no completed date, not a crash.
setup
git branch -q -f base HEAD
task_file task-001 backlog ""
commit_all
task_file task-002 backlog ""
check "a task the head does not carry reads as undated" 0 \
  "task-002 has no completed date in" -- bash "$PREFLIGHT" task-002 base...HEAD
check "and the run still reaches its summary" 0 "PREFLIGHT OK" \
  -- bash "$PREFLIGHT" task-002 base...HEAD

finish

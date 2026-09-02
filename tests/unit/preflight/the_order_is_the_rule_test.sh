#!/usr/bin/env bash
# The three gates run in one order and stop at the first failure: a
# malformed queue file is answered before anything reads a diff, and the
# stages after it do not run at all.
. "$(dirname "$0")/../../pipeline_lib.sh"

setup
task_file task-001 ready ""
printf -- '---\nid: task-002\nstatus: ready\n---\n' > work/tasks/task-002.md
commit_all

check "a front-matter failure stops the run" 1 "1/3 front matter" \
  -- bash "$PREFLIGHT"
refute "and the delta stage never runs" "2/3 promised deltas" -- bash "$PREFLIGHT"
refute "nor the state stage" "3/3 task state" -- bash "$PREFLIGHT"
check "the stage that stopped it is named" 1 "PREFLIGHT STOPPED at 1/3" -- bash "$PREFLIGHT"

setup
task_file task-001 backlog ""
commit_all
check "all three run when the queue is clean" 0 "3/3 task state" -- bash "$PREFLIGHT"
check "and the summary names the range" 0 "PREFLIGHT OK — range" -- bash "$PREFLIGHT"

finish

#!/usr/bin/env bash
# The two positional arguments are told apart by what a task list looks
# like, never by the range's punctuation — so a bare ref is a range and
# reaches the working tree, which is the one shape every stage-2 gate
# already reads that way and the one preflight would not take
# (report-0046, decision 0080).
. "$(dirname "$0")/../../pipeline_lib.sh"

setup
task_file task-001 backlog ""
commit_all
git branch -q -f origin-main HEAD   # a ref to name bare, with no remote

# A bare ref beside a task list: the list is still the list, and the ref
# is the range rather than a second list.
check "a bare ref beside a task list is the range" 0 "PREFLIGHT OK" \
  -- bash "$PREFLIGHT" task-001 origin-main
check "and the summary prints it as given" 0 "range origin-main;" \
  -- bash "$PREFLIGHT" task-001 origin-main
refute "it is never read as a second task list" "two task lists given" \
  -- bash "$PREFLIGHT" task-001 origin-main

# A bare ref alone, on a task branch: the id still comes from the branch.
setup
git checkout -qb task/0001-mirror-lag
task_file task-001 backlog ""
commit_all
git branch -q -f origin-main HEAD
check "a bare ref alone leaves the branch to name the task" 0 \
  "task-001 has no completed date" -- bash "$PREFLIGHT" origin-main
check "and it is the range" 0 "range origin-main;" -- bash "$PREFLIGHT" origin-main

# Every spelling of an id is a task list, and a two-ended range beside it
# is still a range — the shapes that worked before work unchanged.
setup
task_file task-001 backlog ""
commit_all
for id in 1 001 0001 task-001 task-0001; do
  check "'${id}' is a task list, not a range" 0 "task-001 has no completed date" \
    -- bash "$PREFLIGHT" "$id" main...HEAD
done
check "a comma list of ids is one task list" 0 "task-001 has no completed date" \
  -- bash "$PREFLIGHT" task-001,task-0001 main...HEAD
check "a branch-shaped id is a task list" 0 "task-001 has no completed date" \
  -- bash "$PREFLIGHT" task/0001-mirror-lag

# Two of either kind is still preflight's own failure, exit 4.
check "two task lists is still refused" 4 "two task lists given" \
  -- bash "$PREFLIGHT" task-001 0001
check "two ranges is still refused" 4 "two diff ranges given" \
  -- bash "$PREFLIGHT" main...HEAD main..HEAD
check "two bare refs are two ranges" 4 "two diff ranges given" \
  -- bash "$PREFLIGHT" main origin-main
check "an unknown option is still refused" 4 "unknown option" \
  -- bash "$PREFLIGHT" --range

# The documented trade: a ref spelled like an id reads as an id. The
# refusal is the ordinary one, which is what makes the trade legible.
check "a ref spelled like an id reads as an id" 4 "resolves to no file" \
  -- bash "$PREFLIGHT" 0034

finish

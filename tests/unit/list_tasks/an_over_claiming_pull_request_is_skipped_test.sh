#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

# The lister asks ql_carried_of, so it meets the ceiling the machinery
# meets. Without it this reader kept a private parser and no bound: one
# open pull request titled with nine tags moved all nine tasks out of
# Available into In flight, and the reader every session runs first
# printed "Nothing is available." and exited 1 — the queue denial the
# ceiling exists to prevent (spec-0069).
setup
task_file task-0001 ready ""
task_file task-0002 ready ""
export WRITRUN_PR_LIST="$(printf '9\ttask/0001-everything\tmallory\t[TASK-0001][TASK-0002][TASK-0003][TASK-0004][TASK-0005][TASK-0006][TASK-0007][TASK-0008][TASK-0009] all of it')"
out=$(bash "$LIST_TASKS" 2>&1); code=$?

if [ "$code" -eq 0 ] &&
   printf '%s' "$out" | grep -q "task-0001" &&
   printf '%s' "$out" | grep -q "task-0002" &&
   ! printf '%s' "$out" | grep -q "Nothing is available."; then
  echo "ok    an over-claiming row does not empty the available list"; pass=$((pass + 1))
else
  echo "FAIL  an over-claiming row does not empty the available list"
  printf '      exit was %s\n' "$code"
  printf '%s\n' "$out" | sed 's/^/      | /'
  fail=$((fail + 1))
fi

if ! printf '%s' "$out" | grep -q "#9 by @mallory"; then
  echo "ok    and no task it claimed reads as in flight"; pass=$((pass + 1))
else
  echo "FAIL  and no task it claimed reads as in flight"
  printf '%s\n' "$out" | sed 's/^/      | /'
  fail=$((fail + 1))
fi

if printf '%s' "$out" | grep -q "pull request #9 claims 9 distinct tasks" &&
   printf '%s' "$out" | grep -q "ceiling of 8"; then
  echo "ok    the notice names the pull request, the count and the ceiling"; pass=$((pass + 1))
else
  echo "FAIL  the notice names the pull request, the count and the ceiling"
  printf '%s\n' "$out" | sed 's/^/      | /'
  fail=$((fail + 1))
fi

# Eight is not over: the boundary belongs to the lister too, and a
# skip-everything reader would be its own denial.
export WRITRUN_PR_LIST="$(printf '8\tdocs/eight\tdana\t[TASK-0001][TASK-0002][TASK-0003][TASK-0004][TASK-0005][TASK-0006][TASK-0007][TASK-0008] eight of them')"
out=$(bash "$LIST_TASKS" 2>&1)
if printf '%s' "$out" | grep -q "task-0001 *#8 by @dana"; then
  echo "ok    eight distinct tasks still report in flight"; pass=$((pass + 1))
else
  echo "FAIL  eight distinct tasks still report in flight"
  printf '%s\n' "$out" | sed 's/^/      | /'
  fail=$((fail + 1))
fi

finish

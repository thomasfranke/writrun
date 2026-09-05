#!/usr/bin/env bash
. "$(dirname "$0")/../../runner_lib.sh"

# tests/run.sh appended every result to one fixed path under tests/, so
# two runs in the same worktree counted each other's cases as their own
# — this repository reported totals of 795 and 808 against a true 405.
# A green run was manufacturable by overlapping two invocations, which
# is the one property a test runner exists not to have.
#
# The second assertion is the other half of the same change: truncation
# used to be what answered a stale tally, and after the move to a
# private path the trap is. An interrupted run that left its file behind
# would leave the next `mktemp` name to collide with, which is the same
# fault with a longer fuse.

runner_tree

# Slow enough that the two runs are inside each other rather than
# merely adjacent — the fault only shows while both are appending.
export RUNNER_FIXTURE_SLEEP=1

a_out="$WORK/a.out"; b_out="$WORK/b.out"
bash "$ROOT/tests/run.sh" > "$a_out" 2>&1 &
a_pid=$!
bash "$ROOT/tests/run.sh" > "$b_out" 2>&1 &
b_pid=$!
wait "$a_pid"; wait "$b_pid"

total_of() { sed -n 's/^\([0-9]*\) case files passed.*/\1/p' "$1"; }
a_total=$(total_of "$a_out"); b_total=$(total_of "$b_out")

if [ "$a_total" = "$TREE_CASES" ] && [ "$b_total" = "$TREE_CASES" ]; then
  echo "ok    two overlapping runs each report only the cases it ran"
  pass=$((pass + 1))
else
  printf 'FAIL  overlapping runs reported %s and %s, not %s each\n' \
    "$a_total" "$b_total" "$TREE_CASES"
  sed 's/^/      | /' "$a_out" "$b_out"
  fail=$((fail + 1))
fi

# An interrupted run. TMPDIR is given a directory of its own so the
# question "did anything survive" has an answer that is not shared with
# every other process on the machine.
unset RUNNER_FIXTURE_SLEEP
tally_home="$WORK/tallies"; mkdir -p "$tally_home"
slow_out="$WORK/slow.out"
RUNNER_FIXTURE_SLEEP=5 TMPDIR="$tally_home" bash "$ROOT/tests/run.sh" > "$slow_out" 2>&1 &
slow_pid=$!
sleep 1
kill -TERM "$slow_pid" 2>/dev/null
wait "$slow_pid" 2>/dev/null; slow_code=$?

left=$(find "$tally_home" -type f | wc -l | tr -d ' ')
if [ "$left" = "0" ] && [ ! -e "$ROOT/tests/.tally" ]; then
  echo "ok    an interrupted run leaves no tally behind"
  pass=$((pass + 1))
else
  printf 'FAIL  an interrupted run left %s tally file(s) behind\n' "$left"
  find "$tally_home" -type f | sed 's/^/      | /'
  [ -e "$ROOT/tests/.tally" ] && echo "      | tests/.tally"
  fail=$((fail + 1))
fi

# And the half a handler that only removes the file cannot answer. A
# trap replaces the default terminate action, so the run went on: the
# cases after the signal recreated the tally with `>>`, the count saw
# only those, and `fail` reached 0 — an interrupted run reporting a
# green over the cases it never ran. The interrupted run must report
# nothing and exit non-zero.
reported=$(sed -n 's/^\([0-9]*\) case files passed.*/\1/p' "$slow_out")

if [ -z "$reported" ] && [ "$slow_code" -ne 0 ]; then
  echo "ok    an interrupted run reports no tally and exits non-zero"
  pass=$((pass + 1))
else
  printf 'FAIL  an interrupted run reported "%s" and exited %s\n' \
    "$reported" "$slow_code"
  sed 's/^/      | /' "$slow_out"
  fail=$((fail + 1))
fi

finish

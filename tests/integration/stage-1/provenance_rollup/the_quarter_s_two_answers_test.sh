#!/usr/bin/env bash
. "$(dirname "$0")/../../../pipeline_lib.sh"

# The two questions a stakeholder is entitled to ask, answered from what
# was already written down: what did this cost, and what share of it was
# done by an agent (docs/product/concepts/provenance.md).

milestoned() {   # milestoned <file> <milestone>
  sed "s|^milestone: null$|milestone: $2|" "$1" > "$1.tmp" && mv "$1.tmp" "$1"
}

setup

# A task worked by two models across two sessions.
task_file task-0001 done "" null octocat rule 'provenance:
  - {by: agent, model: claude-opus-5, login: octocat, input: 100, output: 200, cache_read: 30000, cache_write: 400}
  - {by: agent, model: claude-fable-5, login: octocat, input: 1, output: 2, cache_read: 3, cache_write: 4}'
milestoned work/tasks/task-0001.md v0.1-core

# A task worked entirely by hand. A complete record, not a missing one —
# and the case that proves the ledger did not quietly make agent use
# mandatory.
task_file task-0002 done "" null octocat rule 'provenance:
  - {by: human, login: octocat}'
milestoned work/tasks/task-0002.md v0.1-core

# A task nobody has worked yet.
task_file task-0003 ready ""
milestoned work/tasks/task-0003.md v0.2

check "the queue is canonical to begin with" 0 "all canonical" \
  -- bash "$CHECK_FRONT_MATTER"

out=$(bash "$PROVENANCE_ROLLUP")

expect() {   # expect <name> <extended-regex>
  if printf '%s\n' "$out" | grep -qE "$2"; then
    echo "ok    $1"; pass=$((pass + 1))
  else
    echo "FAIL  $1"
    echo "      | expected to match: $2"
    printf '%s\n' "$out" | sed 's/^/      | /'
    fail=$((fail + 1))
  fi
}

expect "a task's counts are summed across its entries" \
  '^task-0001 +101 +202 +30003 +404 '
expect "and both its models are named" \
  'task-0001.*claude-opus-5 claude-fable-5'
expect "a hand-worked task appears with no counts and no model" \
  '^task-0002 +0 +0 +0 +0 *$'
expect "the total is the queue's" '^TOTAL +101 +202 +30003 +404 '
expect "three tasks are in scope" '3 task\(s\) in scope'
expect "one of them had agent participation" '1 with agent participation'
expect "and two did not" '2 without'
expect "counts, never money" 'Counts, never money'

# A task with no entries at all is not a row — but it is still counted,
# because "without" is half the answer.
if printf '%s\n' "$out" | grep -q '^task-0003'; then
  echo "FAIL  an empty ledger is not a row of zeroes"
  fail=$((fail + 1))
else
  echo "ok    an empty ledger is not a row of zeroes"; pass=$((pass + 1))
fi

# The milestone is the unit a quarter is actually asked about.
out=$(bash "$PROVENANCE_ROLLUP" --milestone v0.1-core)
expect "a milestone reports its own tasks" '2 task\(s\) in scope \(milestone v0.1-core\)'
expect "and its own sum" '^TOTAL +101 +202 +30003 +404 '
if printf '%s\n' "$out" | grep -q 'task-0003'; then
  echo "FAIL  a task outside the milestone is out of scope"
  fail=$((fail + 1))
else
  echo "ok    a task outside the milestone is out of scope"; pass=$((pass + 1))
fi

out=$(bash "$PROVENANCE_ROLLUP" --milestone v0.2)
expect "and a milestone with no entries reports zero, loudly" \
  '1 task\(s\) in scope \(milestone v0.2\): 0 with agent participation, 1 without'

finish

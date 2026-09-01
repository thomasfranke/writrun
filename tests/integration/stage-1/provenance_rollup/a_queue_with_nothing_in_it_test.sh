#!/usr/bin/env bash
. "$(dirname "$0")/../../../pipeline_lib.sh"

# A project before its first task has an empty queue, not a broken one,
# and the rollup's answer to it is a report of zeroes. The header promises
# "0 always, except 3 for a usage error", and a read-only summary is the
# last place a crash belongs.
setup

mkdir -p empty-queue
out=$(bash "$PROVENANCE_ROLLUP" --tasks empty-queue 2>&1) && code=0 || code=$?
if [ "$code" = "0" ]; then
  echo "ok    a directory holding no task is not an error"; pass=$((pass + 1))
else
  echo "FAIL  a directory holding no task is not an error"
  echo "      | exit $code"
  printf '%s\n' "$out" | sed 's/^/      | /'
  fail=$((fail + 1))
fi

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

expect "the report is still a report" '^TASK +INPUT'
expect "its total is zero" '^TOTAL +0 +0 +0 +0'
expect "and it says so in words" '0 task\(s\) in scope: 0 with agent participation, 0 without'

# A directory that is not there at all is a different answer: the caller
# named somewhere, and nowhere is not an empty queue.
check "a directory that does not exist is a usage error" 3 "no such directory" \
  -- bash "$PROVENANCE_ROLLUP" --tasks nowhere

# An option written last has no value to take. Left to the shell, the
# `shift` past the end is a fatal error under `set -e` — exit 1 and no
# output, a usage error told as a crash.
check "--milestone with nothing after it is a usage error" 3 "takes a value" \
  -- bash "$PROVENANCE_ROLLUP" --milestone
check "and so is --tasks" 3 "takes a value" \
  -- bash "$PROVENANCE_ROLLUP" --tasks

finish

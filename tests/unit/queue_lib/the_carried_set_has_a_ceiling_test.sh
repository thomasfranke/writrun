#!/usr/bin/env bash
# The carried set is bounded at QL_CARRIED_MAX distinct tasks, counted
# after dedup — never on the tags. Above it the helper answers with the
# sentinel `over-ceiling:<count>` alone on stdout and still exits 0,
# because every call site assigns its output bare under
# `set -euo pipefail`, and a non-zero substitution would kill such a
# caller with no message at all (spec-0069).
#
# Sources the harness directly: ql_carried_of reads no repository.
. "$(dirname "$0")/../../harness.sh"

QUEUE_LIB="$REPO_ROOT/.writrun/scripts/stage-2-pull-requests/queue_lib.sh"

carried_of() {
  bash -c 'set -euo pipefail; . "$0"; ql_carried_of "$1" "$2"' \
    "$QUEUE_LIB" "$1" "$2"
}

# exact <name> <want> -- <cmd...> — the whole of stdout, byte for byte,
# and exit 0. The sentinel's contract is "alone on stdout", which a
# substring cannot assert.
exact() {
  local name="$1" want="$2"; shift 3
  local out code
  out=$("$@"); code=$?
  if [ "$code" -ne 0 ]; then
    printf 'FAIL  %s\n      expected exit 0, got %s\n' "$name" "$code"
    fail=$((fail + 1)); return
  fi
  if [ "$out" != "$want" ]; then
    printf 'FAIL  %s\n      expected exactly: %s\n      got:              %s\n' \
      "$name" "$want" "$out"
    fail=$((fail + 1)); return
  fi
  printf 'ok    %s\n' "$name"
  pass=$((pass + 1))
}

# Eight distinct tasks — the branch's own plus seven tags — is at the
# ceiling and passes untouched.
exact "eight distinct tasks are carried and printed" \
  "task-1 task-2 task-3 task-4 task-5 task-6 task-7 task-8" \
  -- carried_of "task/0001-the-work" \
  "[TASK-0002][TASK-0003][TASK-0004][TASK-0005][TASK-0006][TASK-0007][TASK-0008][Feat][Ci] Everything at once"

# One more and the whole set is refused: the sentinel, alone, exit 0.
exact "nine answer with the sentinel alone" \
  "over-ceiling:9" \
  -- carried_of "task/0001-the-work" \
  "[TASK-0002][TASK-0003][TASK-0004][TASK-0005][TASK-0006][TASK-0007][TASK-0008][TASK-0009][Feat][Ci] One too many"

# The count is of the set: a tag repeated twenty times claims one task,
# verbosely, and passes.
exact "one tag repeated twenty times carries one task" \
  "task-1" \
  -- carried_of "" \
  "[TASK-0001][TASK-0001][TASK-0001][TASK-0001][TASK-0001][TASK-0001][TASK-0001][TASK-0001][TASK-0001][TASK-0001][TASK-0001][TASK-0001][TASK-0001][TASK-0001][TASK-0001][TASK-0001][TASK-0001][TASK-0001][TASK-0001][TASK-0001] Loudly one"

finish

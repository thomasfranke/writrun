#!/usr/bin/env bash
. "$(dirname "$0")/../../../pipeline_lib.sh"

# Silence where there is nothing to read. The transcripts sit in one
# vendor's directory on one machine, absent from CI and from every other
# contributor — which is the whole reason the ledger lives in the
# repository rather than there. A helper that failed instead would make
# that directory a precondition for the methodology.
setup
ledger_kept
task_file task-0001 in-progress "" null octocat

export WRITRUN_TRANSCRIPTS="$WORK/nowhere"
check "no transcript directory is not an error" 0 "" -- bash "$READ_USAGE"
if [ -z "$(bash "$READ_USAGE" 2>/dev/null)" ]; then
  echo "ok    and it proposes nothing"; pass=$((pass + 1))
else
  echo "FAIL  and it proposes nothing"; fail=$((fail + 1))
fi

mkdir -p "$WORK/nowhere"
check "an empty directory is not an error either" 0 "" -- bash "$READ_USAGE"

: > "$WORK/nowhere/empty.jsonl"
check "and neither is a transcript with nothing in it" 0 "" -- bash "$READ_USAGE"

if [ -z "$(bash "$READ_USAGE" 2>/dev/null)" ]; then
  echo "ok    still nothing proposed"; pass=$((pass + 1))
else
  echo "FAIL  still nothing proposed"; fail=$((fail + 1))
fi

# A task nobody holds and no login given: named on stderr and skipped,
# never guessed at. The entry says who answers for the work, and there is
# no default answer to that.
task_file task-0002 ready ""
printf '{"message":{"model":"claude-opus-5","usage":{"input_tokens":1,"cache_creation_input_tokens":2,"cache_read_input_tokens":3,"output_tokens":4}},"type":"assistant","sessionId":"s1","gitBranch":"task/0002-x"}\n' \
  > "$WORK/nowhere/s1.jsonl"
check "a task with nobody accountable is named, not guessed" 0 \
  "no taken_by and no --login" \
  -- bash "$READ_USAGE"
if [ -z "$(bash "$READ_USAGE" 2>/dev/null)" ]; then
  echo "ok    and nothing is proposed for it"; pass=$((pass + 1))
else
  echo "FAIL  and nothing is proposed for it"; fail=$((fail + 1))
fi
check "unless a login is handed to it" 0 "login=someone" \
  -- bash "$READ_USAGE" --login someone

finish

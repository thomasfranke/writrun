#!/usr/bin/env bash
. "$(dirname "$0")/../../../pipeline_lib.sh"

# The join already exists: the platform stamps every message with the git
# branch it ran on, and the branch convention puts the task id in that
# name. The helper reads that and nothing else — it proposes, it never
# writes, and it is wired into no check.

# record <session> <model> <branch> <in> <out> <cache-read> <cache-write>
#
# The shape the platform actually writes, `iterations` included. That
# array is not decoration here: it repeats every count, so a helper that
# summed what a naive scan found would multiply the true number by the
# iteration count. The fixture carries it so the case can fail if that
# ever regresses.
record() {
  printf '{"isSidechain":false,"message":{"model":"%s","role":"assistant","usage":{"input_tokens":%s,"cache_creation_input_tokens":%s,"cache_read_input_tokens":%s,"output_tokens":%s,"output_tokens_details":{"thinking_tokens":3},"service_tier":"standard","iterations":[{"input_tokens":%s,"output_tokens":%s,"cache_read_input_tokens":%s,"cache_creation_input_tokens":%s}]}},"type":"assistant","sessionId":"%s","gitBranch":"%s"}\n' \
    "$2" "$4" "$7" "$6" "$5" "$4" "$5" "$6" "$7" "$1" "$3" >> "$T/$1.jsonl"
}

setup
ledger_kept
task_file task-0001 in-progress "" null octocat
T="$WORK/transcripts"; mkdir -p "$T"
export WRITRUN_TRANSCRIPTS="$T"

record s1 claude-opus-5 task/0001-a-thing 10 40 3000 200
record s1 claude-opus-5 task/0001-a-thing 10 40 3000 200

got=$(bash "$READ_USAGE" 2>/dev/null)
want='task-0001 by=agent model=claude-opus-5 login=octocat input=20 output=80 cache_read=6000 cache_write=400'
if [ "$got" = "$want" ]; then
  echo "ok    a session's messages sum into one proposal"; pass=$((pass + 1))
else
  echo "FAIL  a session's messages sum into one proposal"
  echo "      | want: $want"
  echo "      | got:  $got"
  fail=$((fail + 1))
fi

# Several models in one task is normal, not exceptional — this
# repository's own task-0021 ran on two. Each is its own entry, because
# "which agent" is the question the field exists to answer.
record s1 claude-fable-5 task/0001-a-thing 1 2 3 4
if [ "$(bash "$READ_USAGE" 2>/dev/null | wc -l | tr -d ' ')" = "2" ]; then
  echo "ok    a second model in the same session is its own proposal"; pass=$((pass + 1))
else
  echo "FAIL  a second model in the same session is its own proposal"
  bash "$READ_USAGE" 2>&1 | sed 's/^/      | /'
  fail=$((fail + 1))
fi

# A branch that names no task is not a task's cost.
record s2 claude-opus-5 main 999 999 999 999
record s2 claude-opus-5 docs/a-rule 999 999 999 999
refute "work off a task branch is not attributed" "999" \
  -- bash "$READ_USAGE"

# And a task the queue does not have is nobody's.
record s3 claude-opus-5 task/0404-not-here 7 7 7 7
refute "a branch naming an absent task proposes nothing" "task-0404" \
  -- bash "$READ_USAGE"

check "one task can be asked for on its own" 0 "task-0001" \
  -- bash "$READ_USAGE" task-0001

# The proposal is the writer's argument list, so composing them is a pipe
# and not a format.
bash "$READ_USAGE" task-0001 2>/dev/null | while read -r t rest; do
  bash "$RECORD_PROVENANCE" "$t" $rest >/dev/null
done
if [ "$(grep -c '^  - ' work/tasks/task-0001.md)" = "2" ]; then
  echo "ok    and it feeds the writer unchanged"; pass=$((pass + 1))
else
  echo "FAIL  and it feeds the writer unchanged"
  sed -n '1,22p' work/tasks/task-0001.md | sed 's/^/      | /'
  fail=$((fail + 1))
fi
check "leaving the queue canonical" 0 "all canonical" \
  -- bash "$CHECK_FRONT_MATTER"

finish

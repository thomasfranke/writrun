#!/usr/bin/env bash
. "$(dirname "$0")/../../../pipeline_lib.sh"

# The helper's silence is meaningful — no transcripts, no branch naming a
# task, nothing to propose — which is exactly why a *mistyped invocation*
# must never borrow it. A usage error is exit 3 and a sentence, so that
# the composition in the header cannot be handed a wrong scope and told
# nothing about it.
setup
ledger_kept
task_file task-0001 in-progress "" null octocat
task_file task-0002 in-progress "" null octocat

export WRITRUN_TRANSCRIPTS="$WORK/tr"
mkdir -p "$WORK/tr"
for n in 0001 0002; do
  printf '{"message":{"model":"claude-opus-5","usage":{"input_tokens":1,"cache_creation_input_tokens":2,"cache_read_input_tokens":3,"output_tokens":4}},"type":"assistant","sessionId":"s%s","gitBranch":"task/%s-x"}\n' \
    "$n" "$n" >> "$WORK/tr/s.jsonl"
done

check "both tasks are proposed with no argument" 0 "task-0002" -- bash "$READ_USAGE"

# The filter is "this number and no other". An argument naming no number
# yields no number to compare against — and a filter that compares
# against nothing passes everything, which would propose an entry for the
# whole queue and, piped into the writer, stamp the typo onto all of it.
check "an id that names no number is a usage error" 3 "names no task number" \
  -- bash "$READ_USAGE" task-abc
refute "and it proposes nothing at all" "by=agent" -- bash "$READ_USAGE" task-abc

check "the id that does name one still filters to it" 0 "task-0002" \
  -- bash "$READ_USAGE" task-0002
refute "and to it alone" "task-0001" -- bash "$READ_USAGE" task-0002

# An option written last has no value to take. Left to the shell, the
# `shift` past the end is a fatal error under `set -e` — exit 1 and no
# output, a usage error told as a crash.
check "--login with nothing after it is a usage error" 3 "takes a value" \
  -- bash "$READ_USAGE" --login
check "and so is --transcripts" 3 "takes a value" \
  -- bash "$READ_USAGE" --transcripts

finish

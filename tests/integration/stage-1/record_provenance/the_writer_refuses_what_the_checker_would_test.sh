#!/usr/bin/env bash
. "$(dirname "$0")/../../../pipeline_lib.sh"

# A writer that can emit a file its own checker rejects is a writer
# nobody can run unattended: the run reports success, and CI fails on a
# file the sanctioned writer produced. So every rule check_front_matter.sh
# holds an entry to is held here too — including the one that is a
# judgement rather than a shape, that a category is not a model.
setup
ledger_kept
task_file task-0001 ready ""

for category in ai llm agent model assistant bot claude gpt gemini llama \
                opus sonnet haiku fable; do
  out=$(bash "$RECORD_PROVENANCE" task-0001 by=agent "model=$category" \
        login=octocat input=1 output=2 2>&1) && code=0 || code=$?
  if [ "$code" = "1" ] && printf '%s' "$out" | grep -q "is a category, not a model id"; then
    echo "ok    '$category' is refused as a model id"; pass=$((pass + 1))
  else
    echo "FAIL  '$category' is refused as a model id"
    printf '%s\n' "$out" | sed 's/^/      | /'
    fail=$((fail + 1))
  fi
done

check "and the case it was written in does not evade it" 1 \
  "is a category, not a model id" \
  -- bash "$RECORD_PROVENANCE" task-0001 by=agent model=Claude login=octocat

if [ "$(grep -c '^  - ' work/tasks/task-0001.md)" = "0" ]; then
  echo "ok    no refused entry reached the file"; pass=$((pass + 1))
else
  echo "FAIL  no refused entry reached the file"
  sed -n '1,20p' work/tasks/task-0001.md | sed 's/^/      | /'
  fail=$((fail + 1))
fi

# A model id that names a model passes, and the file it produces is one
# the checker accepts — the two halves of the same promise.
check "a named model is written" 0 "appended to" \
  -- bash "$RECORD_PROVENANCE" task-0001 by=agent model=claude-opus-5 \
     login=octocat input=1 output=2
check "and the checker agrees with the writer" 0 "all canonical" \
  -- bash "$CHECK_FRONT_MATTER"

finish

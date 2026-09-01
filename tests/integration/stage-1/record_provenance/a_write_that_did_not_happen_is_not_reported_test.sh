#!/usr/bin/env bash
. "$(dirname "$0")/../../../pipeline_lib.sh"

# The writer is composed into a loop — `read_usage.sh | while read …` —
# and a loop reads exit codes, not prose. So the one thing it may never
# do is copy a file through untouched and report the entry as appended:
# that is the silent wrong answer, and it loses the numbers in the one
# place nobody looks afterwards.
setup
ledger_kept

# A task file whose front matter never opens. The body may still say
# `provenance:` at column 0 — that is prose, and prose is not the field.
cat > work/tasks/task-0001.md <<'MD'
# Test task task-0001

provenance: not the field, only a body line that spells it
MD

check "a file with no front matter is refused" 1 "migrate it first" \
  -- bash "$RECORD_PROVENANCE" task-0001 by=human login=octocat
if [ "$(grep -c '^  - ' work/tasks/task-0001.md)" = "0" ]; then
  echo "ok    and nothing was written into it"; pass=$((pass + 1))
else
  echo "FAIL  and nothing was written into it"
  sed 's/^/      | /' work/tasks/task-0001.md
  fail=$((fail + 1))
fi
refute "and the refusal is not dressed as a write" "appended to" \
  -- bash "$RECORD_PROVENANCE" task-0001 by=human login=octocat

# Front matter that opens and never closes is not front matter. Where it
# ends is the writer's to read, never to decide.
cat > work/tasks/task-0002.md <<'MD'
---
id: task-0002
status: ready
provenance: []
MD

check "front matter that never closes is refused too" 1 "migrate it first" \
  -- bash "$RECORD_PROVENANCE" task-0002 by=human login=octocat
if grep -qx 'provenance: \[\]' work/tasks/task-0002.md; then
  echo "ok    and that file is untouched as well"; pass=$((pass + 1))
else
  echo "FAIL  and that file is untouched as well"
  sed 's/^/      | /' work/tasks/task-0002.md
  fail=$((fail + 1))
fi

# No half-written file is left behind by either refusal.
if [ -z "$(find work/tasks -name '*.tmp' -print -quit)" ]; then
  echo "ok    no temporary file survives a refusal"; pass=$((pass + 1))
else
  echo "FAIL  no temporary file survives a refusal"
  find work/tasks -name '*.tmp' | sed 's/^/      | /'
  fail=$((fail + 1))
fi

# And the well-formed file still gets its entry — the guard rejects the
# malformed, not the ordinary.
task_file task-0003 ready ""
check "a canonical file is still appended to" 0 "appended to" \
  -- bash "$RECORD_PROVENANCE" task-0003 by=human login=octocat
if grep -qx '  - {by: human, login: octocat}' work/tasks/task-0003.md; then
  echo "ok    with the entry in canonical form"; pass=$((pass + 1))
else
  echo "FAIL  with the entry in canonical form"
  sed -n '1,20p' work/tasks/task-0003.md | sed 's/^/      | /'
  fail=$((fail + 1))
fi

finish

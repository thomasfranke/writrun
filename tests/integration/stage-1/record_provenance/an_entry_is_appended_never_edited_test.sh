#!/usr/bin/env bash
. "$(dirname "$0")/../../../pipeline_lib.sh"

# The writer only ever appends. That is the shape of the one permission a
# branch has over a machine field, and it is why `writrun-check-task-state`
# can tell a legitimate write from an edit at all
# (docs/technical/README.md#task-schema).
setup
ledger_kept
task_file task-001 ready ""

check "the empty ledger becomes a block list" 0 "appended to" \
  -- bash "$RECORD_PROVENANCE" task-001 by=agent model=claude-opus-5 \
     login=octocat input=562 output=175853 cache_read=37266324 cache_write=366590
check "and the file is canonical" 0 "all canonical" \
  -- bash "$CHECK_FRONT_MATTER"

check "a second session appends beneath the first" 0 "appended to" \
  -- bash "$RECORD_PROVENANCE" task-001 by=human login=octocat

if [ "$(grep -c '^  - ' work/tasks/task-001.md)" = "2" ]; then
  echo "ok    both entries are there, one to the line"; pass=$((pass + 1))
else
  echo "FAIL  both entries are there, one to the line"
  sed -n '1,22p' work/tasks/task-001.md | sed 's/^/      | /'
  fail=$((fail + 1))
fi

if grep -qx '  - {by: agent, model: claude-opus-5, login: octocat, input: 562, output: 175853, cache_read: 37266324, cache_write: 366590}' work/tasks/task-001.md; then
  echo "ok    and the first is exactly as it was written"; pass=$((pass + 1))
else
  echo "FAIL  and the first is exactly as it was written"
  sed -n '1,22p' work/tasks/task-001.md | sed 's/^/      | /'
  fail=$((fail + 1))
fi

check "the ledger stays canonical" 0 "all canonical" \
  -- bash "$CHECK_FRONT_MATTER"

# Running the same write twice is a double-run, not two sessions.
check "an identical entry is not appended twice" 0 "already carries this exact entry" \
  -- bash "$RECORD_PROVENANCE" task-001 by=human login=octocat

# The keys land in the schema's order whatever order they arrived in, so
# the canonical form is not something the caller has to remember.
task_file task-002 ready ""
bash "$RECORD_PROVENANCE" task-002 cache_write=4 login=octocat output=2 \
  by=agent cache_read=3 model=claude-opus-5 input=1 >/dev/null
if grep -qx '  - {by: agent, model: claude-opus-5, login: octocat, input: 1, output: 2, cache_read: 3, cache_write: 4}' work/tasks/task-002.md; then
  echo "ok    the entry is written in the schema's key order"; pass=$((pass + 1))
else
  echo "FAIL  the entry is written in the schema's key order"
  sed -n '1,22p' work/tasks/task-002.md | sed 's/^/      | /'
  fail=$((fail + 1))
fi

finish

#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

# The generator is the only thing that writes `created`, so it is where
# the shape has to be right — a file born in the old shape would fail the
# canonical check the moment it was created.
setup
bash "$NEW_SH" task "A tracked thing" >/dev/null 2>&1
bash "$NEW_SH" spec task-0001 "Its elaboration" >/dev/null 2>&1
t=work/tasks/task-0001-a-tracked-thing.md
s=work/specs/spec-0001-its-elaboration.md
if grep -qE '^created: [0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z$' "$t" &&
   grep -qE '^created: [0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z$' "$s"; then
  echo "ok    task and spec are both born with a UTC timestamp"; pass=$((pass + 1))
else
  echo "FAIL  task and spec are both born with a UTC timestamp"
  grep -h '^created: ' "$t" "$s" 2>/dev/null | sed 's/^/      | /'
  fail=$((fail + 1))
fi
check "and the generated queue passes its own check" 0 "all canonical" \
  -- bash "$CHECK_FRONT_MATTER"

finish

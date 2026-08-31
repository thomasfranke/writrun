#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

# A spec belongs to exactly one task, and its body says so by linking it.
# The link targets the filename, which never changes — identity is never
# order — so no link here ever needs maintaining.
setup
bash "$NEW_SH" task "A thing" --origin rule --slug thing >/dev/null 2>&1
bash "$NEW_SH" spec task-0001 "Its elaboration" --slug elaboration >/dev/null 2>&1
f=work/specs/spec-0001-elaboration.md
if grep -qF '**References:** [task-0001](../tasks/task-0001-thing.md)' "$f" &&
   grep -q '^task_ref: task-0001$' "$f"; then
  echo "ok    the spec body links back to its task"; pass=$((pass + 1))
else
  echo "FAIL  the spec body links back to its task"
  sed 's/^/      | /' "$f"
  fail=$((fail + 1))
fi

if [ -f work/specs/../tasks/task-0001-thing.md ]; then
  echo "ok    and the link resolves from work/specs/"; pass=$((pass + 1))
else
  echo "FAIL  and the link resolves from work/specs/"; fail=$((fail + 1))
fi

finish

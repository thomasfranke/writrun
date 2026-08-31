#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

# A spec is named the same way its task is, and records the reference the
# queue actually holds: the argument only had to identify the task, so a
# narrower spelling of its number still resolves and still writes the id
# the task file carries.
setup
bash "$NEW_SH" task "A tracked thing" --origin rule >/dev/null 2>&1
bash "$NEW_SH" spec task-1 "Search and replace" >/dev/null 2>&1
if [ -f work/specs/spec-0001-search-and-replace.md ] &&
   grep -q '^id: spec-0001$' work/specs/spec-0001-search-and-replace.md &&
   grep -q '^task_ref: task-0001$' work/specs/spec-0001-search-and-replace.md; then
  echo "ok    a generated spec is named <id>-<subject> and refs the task's own id"; pass=$((pass + 1))
else
  echo "FAIL  a generated spec is named <id>-<subject> and refs the task's own id"
  ls work/specs | sed 's/^/      | /'
  sed -n '1,6p' work/specs/spec-0001-*.md 2>/dev/null | sed 's/^/      | /'
  fail=$((fail + 1))
fi

finish

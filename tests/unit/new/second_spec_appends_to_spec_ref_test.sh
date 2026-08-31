#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

setup
bash "$NEW_SH" task "A tracked thing" --origin rule >/dev/null 2>&1
bash "$NEW_SH" spec task-001 "First" >/dev/null 2>&1
bash "$NEW_SH" spec task-001 "Second" >/dev/null 2>&1
if grep -q '^spec_ref: \[spec-0001, spec-0002\]$' work/tasks/task-0001-a-tracked-thing.md; then
  echo "ok    a second spec appends to spec_ref instead of overwriting"; pass=$((pass + 1))
else
  echo "FAIL  a second spec appends to spec_ref instead of overwriting"
  grep '^spec_ref' work/tasks/task-0001-a-tracked-thing.md | sed 's/^/      | /'
  fail=$((fail + 1))
fi

finish

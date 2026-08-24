#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

setup
bash "$NEW_SH" task "A tracked thing" >/dev/null 2>&1
bash "$NEW_SH" spec task-001 "First" >/dev/null 2>&1
bash "$NEW_SH" spec task-001 "Second" >/dev/null 2>&1
if grep -q '^spec_ref: \[spec-001, spec-002\]$' work/tasks/task-001.md; then
  echo "ok    a second spec appends to spec_ref instead of overwriting"; pass=$((pass + 1))
else
  echo "FAIL  a second spec appends to spec_ref instead of overwriting"
  grep '^spec_ref' work/tasks/task-001.md | sed 's/^/      | /'
  fail=$((fail + 1))
fi

finish

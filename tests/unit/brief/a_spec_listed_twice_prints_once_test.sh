#!/usr/bin/env bash
# A duplicate in spec_ref is a queue-file slip, not a second spec: the
# file is printed once and the duplication is named, so the reader can
# fix the list without reading the same spec twice to find out.
. "$(dirname "$0")/../../pipeline_lib.sh"

setup
task_file task-001 ready "spec-001, spec-001"
spec_file spec-001 task-001 approved

bash "$BRIEF" task-001 > out.txt 2>&1
n=$(grep -c '^== work/specs/spec-001.md ==$' out.txt)
if [ "$n" -eq 1 ]; then
  echo "ok    a spec listed twice is printed once"; pass=$((pass + 1))
else
  echo "FAIL  a spec listed twice is printed once ($n dividers)"
  sed 's/^/      | /' out.txt; fail=$((fail + 1))
fi

check "and the duplication is named" 0 "listed twice" -- bash "$BRIEF" task-001

finish

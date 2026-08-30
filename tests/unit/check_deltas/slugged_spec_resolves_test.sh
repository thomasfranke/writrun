#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

# The generator writes `spec-NNNN-<subject>.md`, so a resolver reading only
# the bare `<id>.md` finds nothing for every spec this project creates —
# and reports it as "spec not found", which points the reader at the id or
# the range rather than at the resolver. Every sibling resolver already
# accepts both shapes; this one must too.
setup
task_file task-0001 done spec-0001 2026-08-28
spec_file spec-0001 task-0001 implemented
mv work/specs/spec-0001.md work/specs/spec-0001-a-subject.md
commit_all
out=$(bash "$CHECK_DELTAS" spec-0001 main...HEAD 2>&1); code=$?
if [ "$code" -ne 3 ] && ! printf '%s' "$out" | grep -q "not found"; then
  echo "ok    a slugged spec resolves by its id"; pass=$((pass + 1))
else
  echo "FAIL  a slugged spec resolves by its id"
  printf '%s\n' "$out" | sed 's/^/      | /'
  fail=$((fail + 1))
fi

finish

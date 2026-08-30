#!/usr/bin/env bash
. "$(dirname "$0")/../../../pipeline_lib.sh"

setup
task_file task-001 ready spec-001
spec_file spec-001 task-001 draft
commit_all
out=$(bash "$CI_SCRIPTS/stage-2-pull-requests/flip_approved_specs.sh" main...HEAD)
if printf '%s' "$out" | grep -q "approved work/specs/spec-001.md" &&
   grep -q '^status: approved$' work/specs/spec-001.md; then
  echo "ok    an added draft spec is flipped to approved"; pass=$((pass + 1))
else
  echo "FAIL  an added draft spec is flipped to approved"
  printf '%s\n' "$out" | sed 's/^/      | /'
  fail=$((fail + 1))
fi

finish

#!/usr/bin/env bash
. "$(dirname "$0")/../../../pipeline_lib.sh"

# Word splitting turns one path holding a space into two paths that exist
# nowhere, each skipped by the `-f` test — the implemented spec never
# collected, and the completion gate reporting "authoring change, deltas
# not applicable" over a change that promised deltas and did not keep
# them. A gate reads every line it was given or refuses; it never drops
# one.
setup
task_file task-001 ready spec-001
spec_file spec-001 task-001 approved product/chapter.md
mv "work/specs/spec-001.md" "work/specs/spec-001-a name.md"
commit_all
git checkout -q main; git merge -q feature; git checkout -q feature
spec_file spec-001 task-001 implemented product/chapter.md
mv "work/specs/spec-001.md" "work/specs/spec-001-a name.md"
task_file task-001 done spec-001 2026-08-22
commit_all

check "the implemented spec is collected through a path holding a space" 1 "spec-001" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/check_promised_deltas.sh" main...HEAD
refute "and the change is never dismissed as an authoring one" "not applicable" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/check_promised_deltas.sh" main...HEAD

finish

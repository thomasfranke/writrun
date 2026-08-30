#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

# Rule C resolves every spec_ref entry to its file. A subject slug in the
# filename is not identity, so a completion whose spec is named
# <id>-<subject> must be judged against that spec — not reported as a
# reference resolving to nothing.
setup
task_file task-0004 ready spec-0001
spec_file spec-0001 task-0004 approved
mv work/specs/spec-0001.md work/specs/spec-0001-queue-file-names.md
commit_all
git checkout -q main; git merge -q feature; git checkout -q feature
task_file task-0004 done spec-0001 2026-08-28
commit_all
check "a spec_ref resolving to a slugged spec is judged, not reported broken" 1 "INCONSISTENT" \
  -- bash "$CHECK_STATE" main...HEAD

finish

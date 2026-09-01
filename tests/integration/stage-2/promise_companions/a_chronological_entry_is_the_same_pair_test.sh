#!/usr/bin/env bash
. "$(dirname "$0")/../../../pipeline_lib.sh"

# `decisions_style` decides whether an entry sits in a subsystem folder or
# in the log's root. The pair is the same pair either way, and the entry
# glob spans the separator so the table stays one row rather than one per
# declared layout.
setup
task_file task-0028 ready spec-0038
spec_file spec-0038 task-0028 draft technical/decisions/0059-the-pause-is-derived.md
commit_all

check "a chronological entry owes the index too" 1 "and not docs/technical/decisions/README.md" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/check_promise_companions.sh" main...HEAD

finish

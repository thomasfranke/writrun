#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

# Completing a multi-spec task in one change: each spec's promise honoured,
# and neither spec's doc is UNDECLARED for the other — the union is the
# contract, not each spec alone against the whole diff.
setup
spec_file spec-001 task-001 approved product/chapter.md
spec_file spec-002 task-001 approved about.md
printf 'edit\n' >> docs/product/chapter.md
printf 'edit\n' >> docs/about.md
commit_all
check "a multi-spec change passes against the union of promises" 0 "OK" \
  -- bash "$CHECK_DELTAS" spec-001,spec-002 main...HEAD

finish

#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

# docs/writrun-instructions.md is process metadata — a completing diff
# may touch it without the spec having promised it.
setup
spec_file spec-001 task-001 approved product/chapter.md
printf 'edit\n' >> docs/product/chapter.md
printf 'meta\n' > docs/writrun-instructions.md
commit_all
check "the instructions file is never UNDECLARED" 0 "OK" \
  -- bash "$CHECK_DELTAS" spec-001 main...HEAD

finish

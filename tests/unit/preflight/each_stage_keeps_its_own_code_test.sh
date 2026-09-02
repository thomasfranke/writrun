#!/usr/bin/env bash
# A failing stage exits with that check's own code, printed under the
# stage's name — attribution is the named line, not the number. And
# preflight's own failures take 4, a code no stage uses, so a caller
# retrying on preflight's word never mistakes a stage's 3 for preflight
# asking for different arguments.
. "$(dirname "$0")/../../pipeline_lib.sh"

# The delta stage: a spec that reached `implemented` promising a doc the
# change never touched.
setup
task_file task-001 in-progress "spec-001"
spec_file spec-001 task-001 approved product/chapter.md
commit_all
spec_file spec-001 task-001 implemented product/chapter.md
sed -i.bak 's/^completed: null$/completed: 2026-08-23T00:00:00Z/' work/tasks/task-001.md
rm -f work/tasks/*.bak
commit_all
check "an unkept promise stops at the delta stage" 1 "2/3 promised deltas" -- bash "$PREFLIGHT" "main...HEAD"
check "with MISSING named" 1 "MISSING" -- bash "$PREFLIGHT" "main...HEAD"
refute "and the state stage never runs" "3/3 task state" -- bash "$PREFLIGHT" "main...HEAD"

# Preflight's own input, which is not a stage's business.
setup
task_file task-001 backlog ""
commit_all
check "an id resolving to nothing exits 4" 4 "resolves to no file" -- bash "$PREFLIGHT" task-404
check "an unknown option exits 4" 4 "unknown option" -- bash "$PREFLIGHT" --deep
check "two ranges exit 4" 4 "two diff ranges" -- bash "$PREFLIGHT" "main...HEAD" "main..HEAD"

finish

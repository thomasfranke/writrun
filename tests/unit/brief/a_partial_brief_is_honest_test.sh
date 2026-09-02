#!/usr/bin/env bash
# What resolved is printed and what did not is named. A brief that
# stopped at the first missing part would hide the rest of the work; one
# that exited 0 would hide the gap.
. "$(dirname "$0")/../../pipeline_lib.sh"

setup
task_file task-001 ready "spec-001, spec-404"
spec_file spec-001 task-001 approved
sed -i.bak 's|^doc_ref: null$|doc_ref: product/chapter.md#scope|' work/tasks/task-001.md
rm -f work/tasks/*.bak

check "an unresolvable spec exits 2"          2 "spec-404" -- bash "$BRIEF" task-001
check "and the resolvable spec still prints"  2 "== work/specs/spec-001.md ==" -- bash "$BRIEF" task-001
check "and so does the doc section after it"  2 "== docs/product/chapter.md#scope ==" -- bash "$BRIEF" task-001
check "the header names it as missing"        2 "spec-404 MISSING" -- bash "$BRIEF" task-001

setup
task_file task-001 ready ""
sed -i.bak 's|^doc_ref: null$|doc_ref: product/chapter.md#no-such-heading|' work/tasks/task-001.md
rm -f work/tasks/*.bak
check "an anchor naming no heading exits 2"   2 "no heading with that anchor" -- bash "$BRIEF" task-001
check "and the task body is printed anyway"   2 "Test task task-001" -- bash "$BRIEF" task-001

setup
task_file task-001 ready ""
sed -i.bak 's|^doc_ref: null$|doc_ref: product/gone.md#scope|' work/tasks/task-001.md
rm -f work/tasks/*.bak
check "a doc_ref naming no file exits 2"      2 "no file at docs/product/gone.md" -- bash "$BRIEF" task-001

finish

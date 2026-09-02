#!/usr/bin/env bash
# The schema writes a doc_ref relative to docs/ — check_front_matter.sh
# refuses one carrying the prefix — so the read is docs/<path>. A reader
# that resolved from the repository root would find a same-named file
# outside docs/ and brief the wrong one.
. "$(dirname "$0")/../../pipeline_lib.sh"

setup
task_file task-001 ready ""
mkdir -p product
printf '# Decoy\n\n## Scope\n\nthe decoy at the repository root\n' > product/chapter.md
sed -i.bak 's|^doc_ref: null$|doc_ref: product/chapter.md#scope|' work/tasks/task-001.md
rm -f work/tasks/*.bak

check "the docs/ copy is the one read" 0 "== docs/product/chapter.md#scope ==" -- bash "$BRIEF" task-001
refute "never the root's same-named file" "the decoy at the repository root" -- bash "$BRIEF" task-001

finish

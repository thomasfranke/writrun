#!/usr/bin/env bash
# A section runs to the next heading of the same or higher level — a
# deeper heading is part of it, a sibling ends it. Getting this wrong
# either truncates the brief or hands over the whole file.
. "$(dirname "$0")/../../pipeline_lib.sh"

setup
task_file task-001 ready ""
cat > docs/product/chapter.md <<'MD'
# Chapter

## First

first body

### Deeper

deeper body

## Second

second body
MD
sed -i.bak 's|^doc_ref: null$|doc_ref: product/chapter.md#first|' work/tasks/task-001.md
rm -f work/tasks/*.bak

check "the section's own body prints"    0 "first body"  -- bash "$BRIEF" task-001
check "a deeper heading rides with it"   0 "deeper body" -- bash "$BRIEF" task-001
refute "the next sibling section does not" "second body" -- bash "$BRIEF" task-001

setup
task_file task-001 ready ""
sed -i.bak 's|^doc_ref: null$|doc_ref: product/chapter.md|' work/tasks/task-001.md
rm -f work/tasks/*.bak
check "no anchor briefs the whole file"  0 "baseline" -- bash "$BRIEF" task-001

finish

#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

# The message names the path, because the fix is repointing and that needs
# the old value visible.
setup

task_file task-001 ready ""
sed -i.bak 's|^doc_ref: null$|doc_ref: product/moved-away.md|' work/tasks/task-001.md && rm -f work/tasks/*.bak
check "a doc_ref naming no file is malformed" 1 \
  "doc_ref 'product/moved-away.md' names no file" \
  -- bash "$CHECK_FRONT_MATTER"
check "and the resolved path is named too" 1 "docs/product/moved-away.md" \
  -- bash "$CHECK_FRONT_MATTER"

# An anchor does not rescue a path that is not there.
task_file task-001 ready ""
sed -i.bak 's|^doc_ref: null$|doc_ref: product/moved-away.md#anchor|' work/tasks/task-001.md && rm -f work/tasks/*.bak
check "an anchor does not rescue a missing file" 1 "names no file" \
  -- bash "$CHECK_FRONT_MATTER"

# A folder is refused for being a folder. Both spellings are one
# mistake, so both get one message — the extension used to split them,
# reporting the `.md` one as absent when it is right there.
task_file task-001 ready ""
mkdir -p docs/product/chapter
sed -i.bak 's|^doc_ref: null$|doc_ref: product/chapter|' work/tasks/task-001.md && rm -f work/tasks/*.bak
check "a folder is refused for being a folder" 1 "names a folder" \
  -- bash "$CHECK_FRONT_MATTER"
refute "and is not reported absent, because it is there" "does not exist" \
  -- bash "$CHECK_FRONT_MATTER"

# A folder spelled like a chapter is the same mistake.
task_file task-001 ready ""
mkdir -p docs/product/folder.md
sed -i.bak 's|^doc_ref: null$|doc_ref: product/folder.md|' work/tasks/task-001.md && rm -f work/tasks/*.bak
check "a folder spelled .md is refused the same way" 1 "names a folder" \
  -- bash "$CHECK_FRONT_MATTER"

# A document is not a file format: a path under docs/ that resolves is a
# doc_ref whatever its extension (report-0041).
task_file task-001 ready ""
mkdir -p docs/product/screens
printf '{"type":"excalidraw"}\n' > docs/product/screens/first-run.excalidraw
sed -i.bak 's|^doc_ref: null$|doc_ref: product/screens/first-run.excalidraw|' work/tasks/task-001.md && rm -f work/tasks/*.bak
check "a drawing that resolves is a doc_ref" 0 "" \
  -- bash "$CHECK_FRONT_MATTER"

# The anchor is unverified on any path, so it is unverified on this one.
task_file task-001 ready ""
sed -i.bak 's|^doc_ref: null$|doc_ref: product/screens/first-run.excalidraw#layout|' work/tasks/task-001.md && rm -f work/tasks/*.bak
check "and an anchor on it changes nothing" 0 "" \
  -- bash "$CHECK_FRONT_MATTER"

# Resolution is still the question it always was.
task_file task-001 ready ""
sed -i.bak 's|^doc_ref: null$|doc_ref: product/screens/never-drawn.excalidraw|' work/tasks/task-001.md && rm -f work/tasks/*.bak
check "a drawing that is not there is still refused" 1 "names no file" \
  -- bash "$CHECK_FRONT_MATTER"

# The docs/ prefix keeps failing for its own reason, not this one.
task_file task-001 ready ""
sed -i.bak 's|^doc_ref: null$|doc_ref: docs/product/chapter.md|' work/tasks/task-001.md && rm -f work/tasks/*.bak
check "a docs/ prefix still fails for being a prefix" 1 \
  "doc_ref starts with docs/" \
  -- bash "$CHECK_FRONT_MATTER"

finish

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

# A directory is not a file, and the message reads the same.
task_file task-001 ready ""
mkdir -p docs/product/chapter
sed -i.bak 's|^doc_ref: null$|doc_ref: product/chapter|' work/tasks/task-001.md && rm -f work/tasks/*.bak
check "a directory is caught by the shape rule first" 1 "is not null or a .md path" \
  -- bash "$CHECK_FRONT_MATTER"

# A .md path that is really a directory reaches the new rule.
task_file task-001 ready ""
mkdir -p docs/product/folder.md
sed -i.bak 's|^doc_ref: null$|doc_ref: product/folder.md|' work/tasks/task-001.md && rm -f work/tasks/*.bak
check "a directory named like a file is not a file" 1 "names no file" \
  -- bash "$CHECK_FRONT_MATTER"

# The docs/ prefix keeps failing for its own reason, not this one.
task_file task-001 ready ""
sed -i.bak 's|^doc_ref: null$|doc_ref: docs/product/chapter.md|' work/tasks/task-001.md && rm -f work/tasks/*.bak
check "a docs/ prefix still fails for being a prefix" 1 \
  "doc_ref starts with docs/" \
  -- bash "$CHECK_FRONT_MATTER"

finish

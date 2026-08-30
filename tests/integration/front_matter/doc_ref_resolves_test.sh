#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

# `doc_ref` is what makes reverse traceability a grep rather than a manual
# search. A reference to a file that is not there passed every check until
# now, which made the grep silently find nothing.
setup

# setup's fixture repository ships docs/product/chapter.md.
task_file task-001 ready ""
sed -i.bak 's|^doc_ref: null$|doc_ref: product/chapter.md|' work/tasks/task-001.md && rm -f work/tasks/*.bak
check "a doc_ref naming a real file is accepted" 0 "all canonical" \
  -- bash "$CHECK_FRONT_MATTER"

# The anchor is deliberately unverified: a heading can be renamed without
# moving the file, and matching one means parsing markdown.
task_file task-001 ready ""
sed -i.bak 's|^doc_ref: null$|doc_ref: product/chapter.md#no-such-heading|' work/tasks/task-001.md && rm -f work/tasks/*.bak
check "an anchor it cannot verify is not a failure" 0 "all canonical" \
  -- bash "$CHECK_FRONT_MATTER"

# Null stays null: a task born in code or machinery references no doc.
task_file task-001 ready ""
check "a null doc_ref is accepted" 0 "all canonical" \
  -- bash "$CHECK_FRONT_MATTER"

finish

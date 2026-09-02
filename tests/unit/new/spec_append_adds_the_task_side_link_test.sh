#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

# The run that appends a spec to a task's spec_ref appends the body link
# in the same edit — front matter and body must never disagree about
# which specs a task has.
setup
# The tracked route travels on its own reporting change, and both
# the generator and check_state read the branch name to hold it there.
git branch -m report/something-seen
bash "$NEW_SH" task "Linked" --origin rule --slug linked \
  --doc-ref product/chapter.md#scope >/dev/null 2>&1
bash "$NEW_SH" spec task-0001 "First" --slug first >/dev/null 2>&1
bash "$NEW_SH" spec task-0001 "Second" --slug second >/dev/null 2>&1
f=work/tasks/task-0001-linked.md
if grep -qF '**References:** [product/chapter.md#scope](../../docs/product/chapter.md#scope) · [spec-0001](../specs/spec-0001-first.md) · [spec-0002](../specs/spec-0002-second.md)' "$f" &&
   grep -q '^spec_ref: \[spec-0001, spec-0002\]$' "$f"; then
  echo "ok    each appended spec joins the one References line"; pass=$((pass + 1))
else
  echo "FAIL  each appended spec joins the one References line"
  sed 's/^/      | /' "$f"
  fail=$((fail + 1))
fi

# A task that had nothing to link gets the line rather than going
# without: the append is what makes the reference exist.
bash "$NEW_SH" task "Bare" --origin report --slug bare >/dev/null 2>&1
bash "$NEW_SH" spec task-0002 "Only" --slug only >/dev/null 2>&1
b=work/tasks/task-0002-bare.md
if grep -qF '**References:** [spec-0003](../specs/spec-0003-only.md)' "$b" &&
   [ "$(sed -n '/^# Bare$/{n;p;}' "$b")" = "" ]; then
  echo "ok    a task with no References line gains one under its heading"; pass=$((pass + 1))
else
  echo "FAIL  a task with no References line gains one under its heading"
  sed 's/^/      | /' "$b"
  fail=$((fail + 1))
fi

check "and the canonical check still passes over the queue" 0 "all canonical" \
  -- bash "$CHECK_FRONT_MATTER"

finish

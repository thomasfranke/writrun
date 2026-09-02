#!/usr/bin/env bash
. "$(dirname "$0")/../../pipeline_lib.sh"

# References are navigable, not just resolvable. The front matter keeps
# the doc_ref as the plain string the line-based readers need; the body
# carries the same fact as a relative link that resolves from
# work/tasks/ — on the forge and in any editor.
setup
# The tracked route travels on its own reporting change, and both
# the generator and check_state read the branch name to hold it there.
git branch -m report/something-seen
bash "$NEW_SH" task "Linked" --origin rule --slug linked \
  --doc-ref product/chapter.md#scope >/dev/null 2>&1
f=work/tasks/task-0001-linked.md
if grep -qF '**References:** [product/chapter.md#scope](../../docs/product/chapter.md#scope)' "$f" &&
   grep -q '^doc_ref: product/chapter.md#scope$' "$f"; then
  echo "ok    the body links the doc_ref the front matter states plainly"; pass=$((pass + 1))
else
  echo "FAIL  the body links the doc_ref the front matter states plainly"
  sed 's/^/      | /' "$f"
  fail=$((fail + 1))
fi

# And the link is a path, not a promise: it resolves from where it sits.
if [ -f "work/tasks/../../docs/product/chapter.md" ]; then
  echo "ok    and the link resolves from work/tasks/"; pass=$((pass + 1))
else
  echo "FAIL  and the link resolves from work/tasks/"; fail=$((fail + 1))
fi

# Nothing to link is not an empty heading: a task with neither a doc_ref
# nor a spec carries no References line at all.
bash "$NEW_SH" task "Bare" --origin report --slug bare >/dev/null 2>&1
if ! grep -q 'References' work/tasks/task-0002-bare.md; then
  echo "ok    a task with nothing to link carries no References line"; pass=$((pass + 1))
else
  echo "FAIL  a task with nothing to link carries no References line"
  sed 's/^/      | /' work/tasks/task-0002-bare.md
  fail=$((fail + 1))
fi

finish

#!/usr/bin/env bash
. "$(dirname "$0")/../../../pipeline_lib.sh"

# The boundary the header draws, on the spec the range *does* touch.
# History is not re-judged: an offending path that already reached the
# base is the completion gate's, and the fix there is an amendment under
# an open pull request — not the one edit this refusal offers. Without
# the base read, a run that merely flips `approved` to `implemented`
# is refused with a message insisting on a fix that no longer exists.
setup
mkdir -p tests/unit
: > tests/unit/keep.sh
task_file task-0028 ready spec-0038
spec_file spec-0038 task-0028 draft "tests/unit/whatever/"
commit_all
git checkout -q main
git merge -q --ff-only feature
git checkout -qb later

# The completion run: the same spec, the same promise, one status line.
sed -i.bak 's/^status: draft$/status: implemented/' work/specs/spec-0038.md
rm -f work/specs/spec-0038.md.bak
commit_all

check "the offending path the base already carried is not re-judged" 0 "every path resolves under docs/" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/check_promise_paths.sh" main...HEAD

# A path the change itself introduces is still refused, in the very same
# spec — the base read is a boundary, never an amnesty.
sed -i.bak 's|^- `tests/unit/whatever/` — test promise.$|- `tests/unit/whatever/` — test promise.\
- `template/newly/` — test promise.|' work/specs/spec-0038.md
rm -f work/specs/spec-0038.md.bak
mkdir -p template
: > template/keep.txt
commit_all

check "and a path the same change adds is still refused" 1 "template/newly/" \
  -- bash "$CI_SCRIPTS/stage-2-pull-requests/check_promise_paths.sh" main...HEAD

finish
